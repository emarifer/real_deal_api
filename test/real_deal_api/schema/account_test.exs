defmodule RealDealApi.Schema.AccountTest do
  alias Ecto.Changeset
  use RealDealApi.DataCase

  alias RealDealApi.Accounts.Account

  @expected_fields_with_types [
    {:id, :binary_id},
    {:email, :string},
    {:hash_password, :string},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  # ↑↑↑ see note1 below. ↑↑↑

  @optional [:id, :inserted_at, :updated_at]

  describe "fields and types for `Account` schema" do
    test "`Account` schema has the correct fields and types" do
      actual_fields_with_types =
        for field <- Account.__schema__(:fields) do
          type = Account.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = %{
        "id" => Ecto.UUID.generate(),
        "email" => "test@email.com",
        "hash_password" => "test password",
        "inserted_at" => DateTime.utc_now() |> DateTime.truncate(:second),
        "updated_at" => DateTime.utc_now() |> DateTime.truncate(:second)
      }

      # ↑↑↑ see note2 below. ↑↑↑

      changeset = Account.changeset(%Account{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      mutated = [:hash_password]

      for {field, _} <- @expected_fields_with_types, field not in mutated do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      # Since the hash is random, we do the password verification separately.
      assert Bcrypt.verify_pass(valid_params["hash_password"], changes.hash_password),
             "Password: #{inspect(valid_params["hash_password"])} does not match \nhash: #{inspect(changes.hash_password)}"
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = %{
        "id" => DateTime.utc_now() |> DateTime.truncate(:second),
        "email" => DateTime.utc_now() |> DateTime.truncate(:second),
        "hash_password" => DateTime.utc_now() |> DateTime.truncate(:second),
        "inserted_at" => "lets put a string here",
        "updated_at" => "updated to a string"
      }

      assert %Changeset{valid?: false, errors: errors} =
               Account.changeset(%Account{}, invalid_params)

      for {field, _} <- @expected_fields_with_types do
        assert errors[field], "The field: #{field} is misssing from errors."

        {_, meta} = errors[field]

        # We claim it is a casting error
        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               Account.changeset(%Account{}, params)

      #  We perform validation for non-optional (i.e. required) fields. ↓↓↓
      for {field, _} <- @expected_fields_with_types, field not in @optional do
        assert errors[field], "The field: #{field} is misssing from errors."

        {_, meta} = errors[field]

        # In this case, the error is not in the `casting`
        # but rather that it is a required field.
        assert meta[:validation] == :required,
               "The validation type, #{meta[:validation]}, is incorrect."
      end

      for field <- @optional do
        # If any optional field is present in the error list (not `nil`, i.e.
        # not truthy) we throw an error (`refute` is the inverse of `assert`)
        refute errors[field], "The optional field #{field} is required when it shouldn't be."
      end
    end
  end
end

# NOTE1 ==>
# Difference in between :utc_datetime and :naive_datetime in Ecto:
# https://elixirforum.com/t/difference-in-between-utc-datetime-and-naive-datetime-in-ecto/12551
# In the migration file
# (priv/repo/migrations/20250313165938_create_accounts.exs) in Phoenix
# schema generator, it now uses `:utc_datetime` by default.

# NOTE2 ==>
# `DateTime.utc_now/0` generates decimals in seconds so it does not match what
# comes from `Ecto.changeset/2`, so you have to truncate the input parameters
# to seconds using `DateTime.truncate/2`:
# https://stackoverflow.com/questions/53717074/insert-all-does-not-match-type-utc-datetime#53718084

# casting error ==>
# Account.changeset(%Account{}, invalid_params) ==>
# Ecto.Changeset<
# action: nil,
# changes: %{},
# errors: [
#   id: {"is invalid", [type: :binary_id, validation: :cast]},
#   email: {"is invalid", [type: :string, validation: :cast]},
#   hash_password: {"is invalid", [type: :string, validation: :cast]},
#   inserted_at: {"is invalid", [type: :utc_datetime, validation: :cast]},
#   updated_at: {"is invalid", [type: :utc_datetime, validation: :cast]}
# ],
# data: #RealDealApi.Accounts.Account<>,
# valid?: false,
# ...
# >

# required error ==>
# Ecto.Changeset<
# action: nil,
# changes: %{},
# errors: [
#   email: {"can't be blank", [validation: :required]},
#   hash_password: {"can't be blank", [validation: :required]}
# ],
# data: #RealDealApi.Accounts.Account<>,
# valid?: false,
# ...
# >
