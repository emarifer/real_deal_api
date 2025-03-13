defmodule RealDealApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RealDealApi.Accounts` context.
  """

  @doc """
  Generate a unique account email.
  """
  def unique_account_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        email: unique_account_email(),
        hash_password: "some hash_password"
      })
      |> RealDealApi.Accounts.create_account()

    account
  end
end
