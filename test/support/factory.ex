defmodule RealDealApi.Factory do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RealDealApi.Accounts` context.
  """
  use ExMachina.Ecto, repo: RealDealApi.Repo

  alias RealDealApi.Accounts.Account

  def account_factory do
    %Account{
      email: Faker.Internet.email(),
      hash_password: Faker.Internet.slug()
    }
  end
end
