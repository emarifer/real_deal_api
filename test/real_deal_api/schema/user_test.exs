defmodule RealDealApi.Schema.UserTest do
  use RealDealApi.DataCase

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
end
