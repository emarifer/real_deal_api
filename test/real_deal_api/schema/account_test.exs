defmodule RealDealApi.Schema.AccountTest do
  use RealDealApi.SchemaCase

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
      valid_params = valid_params(@expected_fields_with_types)

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
      invalid_params = invalid_params(@expected_fields_with_types)

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

    test "error: returns error changeset when an email address is reused" do
      Ecto.Adapters.SQL.Sandbox.checkout(RealDealApi.Repo)

      {:ok, existing_account} =
        %Account{}
        |> Account.changeset(valid_params(@expected_fields_with_types))
        |> RealDealApi.Repo.insert()

      changeset_with_repeated_email =
        %Account{}
        |> Account.changeset(
          valid_params(@expected_fields_with_types)
          |> Map.put("email", existing_account.email)
        )

      assert {:error, %Changeset{valid?: false, errors: errors}} =
               RealDealApi.Repo.insert(changeset_with_repeated_email)

      assert errors[:email], "The field :email is misssing from errors."

      {_, meta} = errors[:email]

      # We claim this is a unique constraint error
      assert meta[:constraint] == :unique,
             "The constraint type, #{meta[:constraint]}, is incorrect."
    end
  end
end

# NOTE1 ==>
# Difference in between :utc_datetime and :naive_datetime in Ecto:
# https://elixirforum.com/t/difference-in-between-utc-datetime-and-naive-datetime-in-ecto/12551
# In the migration file
# (priv/repo/migrations/20250313165938_create_accounts.exs) in Phoenix
# schema generator, it now uses `:utc_datetime` by default.

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

# How to view the constraints of a table through the Ecto.Changeset object:
# changeset.constraints ==>
# [
#   %{
#     match: :exact,
#     type: :unique,
#     constraint: "accounts_email_index",
#     error_type: :unique,
#     field: :email,
#     error_message: "has already been taken"
#   }
# ]
