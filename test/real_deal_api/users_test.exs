defmodule RealDealApi.UsersTest do
  use RealDealApi.DataCase

  alias RealDealApi.{Accounts, Accounts.Account, Users, Users.User}

  # Initial configuration for all tests in this module
  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(RealDealApi.Repo)
  end

  describe "create_user/2" do
    test "success: it inserts an user in the db and returns the user" do
      account_with_user_params = Factory.string_params_for(:accountfull)

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
