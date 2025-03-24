defmodule RealDealApi.UsersTest do
  use RealDealApi.DataCase

  alias RealDealApi.{Accounts, Accounts.Account, Users, Users.User}

  # Initial configuration for all tests in this module
  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(RealDealApi.Repo)
  end

  describe "create_user/2" do
    test "success: it inserts an user in the db and returns the user" do
      params = Factory.string_params_for(:account)

      # We create a map with some field of the `User` object as "full_name".
      # The mandatory field `account_id` will be provided by
      # the id of the `Account` object created in the DB.
      account_with_user_params =
        Map.put(
          params,
          "full_name",
          Faker.Person.Es.first_name() <> " " <> Faker.Person.Es.last_name()
        )

      # This has already been tested in `AccountsTest`.
      {:ok, returned_account} =
        Accounts.create_account(account_with_user_params)

      assert {:ok, %User{} = returned_user} =
               Users.create_user(returned_account, account_with_user_params)

      # We verify that the returned value is the one inserted into the DB.
      user_from_db = Repo.get(User, returned_user.id)

      assert returned_user == user_from_db
    end

    test "error: returns an error tuple when user can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} =
               Users.create_user(%Account{}, missing_params)
    end
  end
end
