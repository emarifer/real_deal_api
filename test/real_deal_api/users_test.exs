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

  describe "get_user!/1" do
    test "success: it returns an user when given a valid UUID" do
      existing_full_account = Factory.insert(:accountfull)
      assert user_from_db = Users.get_user!(existing_full_account.user.id)

      assert existing_full_account.user == user_from_db
    end

    test "error: raises a Ecto.NoResultsError when an user doesn't exist" do
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(Ecto.UUID.autogenerate()) end
    end
  end

  describe "update_user/2" do
    test "success: it updates database and returns the user" do
      existing_full_account = Factory.insert(:accountfull)

      params = Factory.string_params_for(:user) |> Map.take(["full_name"])

      assert {:ok, returned_user} = Users.update_user(existing_full_account.user, params)

      user_from_db = Repo.get(User, returned_user.id)

      assert returned_user == user_from_db

      expected_user_data =
        existing_full_account.user
        |> Map.from_struct()
        |> Map.put(:full_name, params["full_name"])

      for {field, expected} <- expected_user_data do
        actual = Map.get(user_from_db, field)

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error tuple when user can't be updated" do
      existing_full_account = Factory.insert(:accountfull)

      bad_params = %{"full_name" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Users.update_user(existing_full_account.user, bad_params)

      assert existing_full_account.user == Repo.get(User, existing_full_account.user.id)
    end
  end
end
