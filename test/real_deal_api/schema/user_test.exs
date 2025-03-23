defmodule RealDealApi.Schema.UserTest do
  use RealDealApi.SchemaCase

  alias RealDealApi.Users.User

  @expected_fields_with_types [
    {:id, :binary_id},
    {:full_name, :string},
    {:gender, :string},
    {:biography, :string},
    {:account_id, :binary_id},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  @optional [:id, :full_name, :gender, :biography, :inserted_at, :updated_at]

  describe "fields and types for`User` schema" do
    test "`User` schema has the correct fields and types" do
      actual_fields_with_types =
        for field <- User.__schema__(:fields) do
          type = User.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@expected_fields_with_types)

      changeset = User.changeset(%User{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @expected_fields_with_types do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = invalid_params(@expected_fields_with_types)

      assert %Changeset{valid?: false, errors: errors} =
               User.changeset(%User{}, invalid_params)

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
               User.changeset(%User{}, params)

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
