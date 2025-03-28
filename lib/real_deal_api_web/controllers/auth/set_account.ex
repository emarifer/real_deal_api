defmodule RealDealApiWeb.Auth.SetAccount do
  @behaviour Plug

  import Plug.Conn

  alias RealDealApi.Accounts

  def init(_opts) do
    #
  end

  def call(conn, _opts) do
    if conn.assigns[:account] do
      conn
    else
      account_id = get_session(conn, :account_id)

      manage_account(account_id, conn)
    end
  end

  defp manage_account(nil, conn),
    do:
      conn
      |> RealDealApiWeb.Router.handle_errors(%{
        reason: :unauthorized,
        message: "You are not logged in"
      })

  defp manage_account(account_id, conn) do
    account = Accounts.get_full_account(account_id)

    # See note below
    cond do
      account_id && account -> assign(conn, :account, account)
      true -> assign(conn, :account, nil)
    end
  end
end

# NOTE:
# If an account logs out (we will add this endpoint later)
# or if it's an unauthorized request, we want to ensure that no stale or
# unauthorized account information is linked to the current session or
# connection. By setting the account to nil, we are effectively
# removing any linkage to a previous or non-existent account
