defmodule RealDealApiWeb.AccountJSON do
  alias RealDealApi.Accounts.Account

  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  @doc """
  Renders a single account.
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

  defp data(%{account: %Account{} = account, token: token}) do
    %{
      id: account.id,
      email: account.email,
      token: token
    }
  end

  # defp data(%Account{} = account) do
  #   %{
  #     id: account.id,
  #     email: account.email,
  #     hash_password: account.hash_password
  #   }
  # end
end
