defmodule RealDealApiWeb.AccountController do
  use RealDealApiWeb, :controller

  alias RealDealApiWeb.Auth.Guardian
  alias RealDealApi.{Accounts, Accounts.Account, Users, Users.User}

  import RealDealApiWeb.Auth.AuthorizedPlug

  plug :is_authorized when action in [:update, :delete]

  action_fallback RealDealApiWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      authorize_account(conn, account.email, account_params["hash_password"], :created)
    end
  end

  # in case the `account` argument is missing
  def create(_conn, %{}), do: {:error, :bad_request}

  def sign_in(conn, %{"email" => email, "hash_password" => hash_password}) do
    authorize_account(conn, email, hash_password, :ok)
  end

  # in case some of the arguments are missing
  def sign_in(_conn, %{}), do: {:error, :bad_request}

  defp authorize_account(conn, email, hash_password, status) do
    with {:ok, account, token} <- Guardian.authenticate(email, hash_password) do
      conn
      |> Plug.Conn.put_session(:account_id, account.id)
      |> put_status(status)
      |> render(:show_account_token, %{account: account, token: token})
    end
  end

  def refresh_session(conn, %{}) do
    old_token = Guardian.Plug.current_token(conn)

    with {:ok, account, new_token} <- Guardian.authenticate(old_token) do
      conn
      |> Plug.Conn.put_session(:account_id, account.id)
      |> put_status(:ok)
      |> render(:show_account_token, %{account: account, token: new_token})
    end
  end

  def sign_out(conn, %{}) do
    account = conn.assigns[:account]
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> Plug.Conn.clear_session()
    |> put_status(:ok)
    |> render(:show_account_token, %{account: account, token: nil})
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_full_account(id) do
      nil -> {:error, :not_found}
      account -> render(conn, :show, account: account)
    end
  rescue
    _e in Ecto.Query.CastError ->
      {:error, :bad_request}
  end

  def current_account(conn, %{}) do
    conn
    |> put_status(:ok)
    |> render(:show, account: conn.assigns.account)
  end

  def update(
        conn,
        %{"current_hash" => current_hash, "account" => account_params}
      ) do
    case Guardian.validate_password?(current_hash, conn.assigns.account.hash_password) do
      true ->
        with {:ok, %Account{} = account} <-
               Accounts.update_account(conn.assigns.account, account_params) do
          render(conn, :show, account: account)
        end

      false ->
        {:error, :unauthorized}
    end
  end

  def update(_conn, %{}), do: {:error, :bad_request}

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end

# REFERENCES:
# It’s possible to match multiple errors in a single rescue:
# https://elixirschool.com/en/lessons/intermediate/error_handling#error-handling-1

# https://hoppscotch.io/

# Alternative implementation for the `refresh_session` action:
# def refresh_session(conn, %{}) do
# old_token = Guardian.Plug.current_token(conn)

# case Guardian.decode_and_verify(old_token) do
#   {:ok, claims} ->
#     case Guardian.resource_from_claims(claims) do
#       {:ok, account} ->
#         {:ok, _old, {new_token, _new_claims}} = Guardian.refresh(old_token)

#         conn
#         |> Plug.Conn.put_session(:account_id, account.id)
#         |> put_status(:ok)
#         |> render(:show_account_token, %{account: account, token: new_token})

#       {:error, _reason} ->
#         {:error, :not_found}
#     end

#   {:error, _reason} ->
#     {:error, :not_found}
#   end
# end

# Alternative implementation for the authentication:
# case Guardian.authenticate(email, hash_password) do
#   {:ok, account, token} ->
#     conn
#     |> put_status(:ok)
#     |> render(:show_account_token, %{account: account, token: token})

#   {:error, :unauthorized} ->
#     raise ErrorResponse.Unauthorized, message: "Email or Password incorrect."
# end
# ↑↑↑ Custom handling using exceptions ↑↑↑
# https://hexdocs.pm/phoenix/json_and_apis.html#action-fallback
# https://hexdocs.pm/phoenix/custom_error_pages.html
# ↓↓↓                                          ↓↓↓
# defmodule RealDealApiWeb.Auth.ErrorResponse.Unauthorized do
#   defexception message: "Unauthorized", plug_status: 401
# end

# This `plug` acts as a `middleware` (passes through or throws an error).
# Prevents any user (even if authenticated) from updating or
# deleting another user's account.
# defp is_authorized_account(conn, _opts) do
#   %{params: %{"account" => params}} = conn
#   account = Accounts.get_account!(params["id"])

#   case conn.assigns.account.id == account.id do
#     true ->
#       conn

#     _ ->
#       conn
#       |> Router.handle_errors(%{
#         reason: :forbidden,
#         message: "You do not have access to this resource."
#       })
#   end
# rescue
#   e in ArgumentError ->
#     conn
#     |> Router.handle_errors(%{
#       reason: :bad_request,
#       message: "ArgumentError: #{e.message}."
#     })

#   _e in Ecto.Query.CastError ->
#     conn
#     |> Router.handle_errors(%{
#       reason: :bad_request,
#       message: "Malformed input data."
#     })

#   _e in Ecto.NoResultsError ->
#     conn
#     |> Router.handle_errors(%{
#       reason: :not_found,
#       message: "There is no resource with that ID."
#     })
# end
