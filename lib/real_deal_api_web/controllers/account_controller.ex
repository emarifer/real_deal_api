defmodule RealDealApiWeb.AccountController do
  use RealDealApiWeb, :controller

  alias RealDealApiWeb.Router
  alias RealDealApiWeb.Auth.Guardian
  alias RealDealApi.{Accounts, Accounts.Account, Users, Users.User}

  action_fallback RealDealApiWeb.FallbackController

  plug :is_authorized_account when action in [:update, :delete]

  # def handle_errors({conn, status, message}),
  #   do:
  #     conn
  #     |> put_status(status)
  #     |> json(%{errors: message})
  #     |> halt()

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(account),
         {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      conn
      |> put_status(:created)
      |> render(:show_account_token, %{account: account, token: token})
    end
  end

  def sign_in(conn, %{"email" => email, "hash_password" => hash_password}) do
    with {:ok, account, token} <- Guardian.authenticate(email, hash_password) do
      conn
      |> Plug.Conn.put_session(:account_id, account.id)
      |> put_status(:ok)
      |> render(:show_account_token, %{account: account, token: token})
    end

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
  end

  # in case some of the arguments are missing
  def sign_in(_conn, %{}), do: {:error, :bad_request}

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, :show, account: account)
  rescue
    _e in Ecto.Query.CastError ->
      {:error, :bad_request}

    _e in Ecto.NoResultsError ->
      {:error, :not_found}
  end

  def update(conn, %{"account" => account_params}) do
    account = Accounts.get_account!(account_params["id"])

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, :show, account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end

  # This `plug` acts as a `middleware` (passes through or throws an error).
  # Prevents any user (even if authenticated) from updating or
  # deleting another user's account.
  defp is_authorized_account(conn, _opts) do
    %{params: %{"account" => params}} = conn
    account = Accounts.get_account!(params["id"])

    case conn.assigns.account.id == account.id do
      true ->
        conn

      _ ->
        conn
        |> Router.handle_errors(%{
          reason: :forbidden,
          message: "You do not have access to this resource."
        })
    end
  rescue
    e in ArgumentError ->
      conn
      |> Router.handle_errors(%{
        reason: :bad_request,
        message: "ArgumentError: #{e.message}."
      })

    _e in Ecto.Query.CastError ->
      conn
      |> Router.handle_errors(%{
        reason: :bad_request,
        message: "Malformed input data."
      })

    _e in Ecto.NoResultsError ->
      conn
      |> Router.handle_errors(%{
        reason: :not_found,
        message: "There is no resource with that ID."
      })
  end
end

# REFERENCES:
# It’s possible to match multiple errors in a single rescue:
# https://elixirschool.com/en/lessons/intermediate/error_handling#error-handling-1

# https://hoppscotch.io/
