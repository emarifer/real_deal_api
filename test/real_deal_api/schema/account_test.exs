defmodule RealDealApi.Schema.AccountTest do
  use RealDealApi.DataCase

  alias RealDealApi.Accounts.Account

  @expected_fields_with_types [
    {:id, :binary_id},
    {:email, :string},
    {:hash_password, :string},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  # ↑↑↑ see note below. ↑↑↑

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
end

# NOTE ==>
# Difference in between :utc_datetime and :naive_datetime in Ecto:
# https://elixirforum.com/t/difference-in-between-utc-datetime-and-naive-datetime-in-ecto/12551
# In the migration file
# (priv/repo/migrations/20250313165938_create_accounts.exs) in Phoenix
# schema generator, it now uses `:utc_datetime` by default.
