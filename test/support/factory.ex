defmodule RealDealApi.Factory do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RealDealApi.Accounts` context.
  """
  use ExMachina.Ecto, repo: RealDealApi.Repo

  alias RealDealApi.{Accounts.Account, Users.User}

  def account_factory do
    %Account{
      email: Faker.Internet.email(),
      hash_password: Faker.Internet.slug()
    }
  end

  def accountfull_factory do
    %Account{
      email: Faker.Internet.email(),
      hash_password: Faker.Internet.slug(),
      user: build(:user)
    }
  end

  # ↑↑↑ See: https://hexdocs.pm/ex_machina/readme.html#ecto-associations ↑↑↑

  def user_factory do
    %User{
      full_name: Faker.Person.Es.first_name() <> " " <> Faker.Person.Es.last_name()
    }
  end
end
