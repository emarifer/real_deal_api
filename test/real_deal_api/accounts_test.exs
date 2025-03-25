defmodule RealDealApi.AccountsTest do
  use RealDealApi.DataCase

  alias RealDealApi.{Accounts, Accounts.Account}

  # Initial configuration for all tests in this module
  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(RealDealApi.Repo)
  end

  describe "create_account/1" do
    test "success: it inserts an account in the db and returns the account" do
      # Returns a map of attributes to be consumed in context functions:
      # https://hexdocs.pm/ex_machina/ExMachina.Ecto.html#c:string_params_for/1
      params = Factory.string_params_for(:account)

      assert {:ok, %Account{} = returned_account} =
               Accounts.create_account(params)

      # We verify that the returned value is the one inserted into the DB.
      account_from_db = Repo.get(Account, returned_account.id)

      assert returned_account == account_from_db

      mutated = ["hash_password"]

      # {param_field, expected} ==> {key for the field, value for the field}
      # ↓↓↓ They are tuples because we are traversing a map. ↓↓↓
      for {param_field, expected} <- params, param_field not in mutated do
        # ↓↓↓ See NOTE below about the `String.to_existing_atom/1` function ↓↓↓
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(account_from_db, schema_field)

        assert actual == expected,
               "Value did not match for field: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      # We check the password separately, since the value stored
      # in the DB is hashed.
      assert Bcrypt.verify_pass(params["hash_password"], returned_account.hash_password),
             "Password: #{inspect(params["hash_password"])} does not match\nhash: #{inspect(returned_account.hash_password)}"

      assert account_from_db.inserted_at == account_from_db.updated_at
    end

    test "error: returns an error tuple when account can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} =
               Accounts.create_account(missing_params)
    end
  end

  describe "get_account!/1" do
    test "success: it returns an account when given a valid UUID" do
      existing_account = Factory.insert(:account)
      assert returned_account = Accounts.get_account!(existing_account.id)

      assert returned_account == existing_account
    end

    test "error: raises a Ecto.NoResultsError when an account doesn't exist" do
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(Ecto.UUID.autogenerate()) end
    end
  end

  describe "get_account_by_email/1" do
    test "success: it returns an account when given a valid email" do
      existing_account = Factory.insert(:account)
      assert returned_account = Accounts.get_account_by_email(existing_account.email)

      assert returned_account == existing_account
    end

    test "error: returns nil when there is no account with the given email" do
      refute Accounts.get_account_by_email(Faker.Internet.email()),
             "The return value of the `get_account_by_email/1` function is not nil when it should be."
    end
  end

  describe "get_full_account/1" do
    test "success: Returns a full acount when a valid UUID is provided" do
      existing_full_account = Factory.insert(:accountfull)
      assert returned_account = Accounts.get_full_account(existing_full_account.id)

      assert returned_account == existing_full_account
    end

    test "error: returns nil when there is no full account with the given UUID" do
      refute Accounts.get_full_account(Ecto.UUID.autogenerate()),
             "The return value of the `get_full_account/1` function is not nil when it should be."
    end
  end

  describe "update_account/2" do
    test "success: it updates database and returns the account" do
      existing_account = Factory.insert(:account)

      params = Factory.string_params_for(:account) |> Map.take(["email"])

      assert {:ok, returned_account} = Accounts.update_account(existing_account, params)

      account_from_db = Repo.get(Account, returned_account.id)

      assert returned_account == account_from_db

      expected_account_data =
        existing_account
        |> Map.from_struct()
        |> Map.put(:email, params["email"])

      for {field, expected} <- expected_account_data do
        actual = Map.get(account_from_db, field)

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error tuple when account can't be updated" do
      existing_account = Factory.insert(:account)

      bad_params = %{"email" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Accounts.update_account(existing_account, bad_params)

      assert existing_account == Repo.get(Account, existing_account.id)
    end
  end
end

# NOTE:
# iex(1)> String.to_existing_atom("hola")
# ** (ArgumentError) errors were found at the given arguments:

#   * 1st argument: not an already existing atom

#     :erlang.binary_to_existing_atom("hola")
#     iex:1: (file)
# iex(1)> String.to_atom("hola")
# :hola
# iex(2)> String.to_existing_atom("hola")
# :hola
