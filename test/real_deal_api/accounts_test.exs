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

      #  We verify that the returned value is the one inserted into the DB.
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
