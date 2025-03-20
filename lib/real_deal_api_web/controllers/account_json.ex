defmodule RealDealApiWeb.AccountJSON do
  alias RealDealApi.{Accounts.Account, Users.User}
  alias RealDealApiWeb.UserJSON

  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc """
  Renders a single account, which may include the associated user.
  """
  def show(%{account: account}) do
    %{data: data(account)}
  end

  @doc """
  Renders a single account with token.
  """
  def show_account_token(%{account: account, token: token}) do
    %{data: data(%{account: account, token: token})}
  end

  defp data(%Account{id: id, email: email, user: %User{} = user}) do
    %{
      id: id,
      email: email,
      user: UserJSON.show(%{user: user})
    }
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      email: account.email,
      hash_password: account.hash_password
    }
  end

  defp data(%{account: %Account{} = account, token: token}) do
    %{
      id: account.id,
      email: account.email,
      token: token
    }
  end
end
