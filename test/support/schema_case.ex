defmodule RealDealApi.SchemaCase do
  @moduledoc """
  This module contains convenience functions for creating
  realistic fake data (using the `Faker` library) for testing.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ecto.Changeset
      import RealDealApi.SchemaCase
    end
  end

  # About configuring the connection to the database for testing:
  # https://youtu.be/M3iWksKfSZk?si=uyVx4xs-v17HivCQ&t=721
  # https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.Sandbox.html
  setup _ do
    Ecto.Adapters.SQL.Sandbox.mode(RealDealApi.Repo, :manual)
  end

  def valid_params(fields_with_types) do
    valid_value_by_type = %{
      binary_id: fn -> Faker.UUID.v4() end,
      string: fn -> Faker.Lorem.word() end,
      utc_datetime: fn ->
        Faker.DateTime.backward(Enum.random(0..100)) |> DateTime.truncate(:second)
      end
    }

    # ↑↑↑ see note below. ↑↑↑

    for {field, type} <- fields_with_types, into: %{} do
      case field do
        :email ->
          {Atom.to_string(field), Faker.Internet.email()}

        _ ->
          {Atom.to_string(field), valid_value_by_type[type].()}
      end
    end
  end

  def invalid_params(fields_with_types) do
    invalid_value_by_type = %{
      binary_id: fn -> DateTime.utc_now() end,
      string: fn -> DateTime.utc_now() end,
      utc_datetime: fn -> Faker.Lorem.word() end
    }

    for {field, type} <- fields_with_types, into: %{} do
      {Atom.to_string(field), invalid_value_by_type[type].()}
    end
  end
end

# WARNING: For these functions to compile when running tests (`mix test`),
# the `test/support` directory must be declared in the
# `defp elixirc_paths(:test), do: ["lib", "test/support"]` function
# in the `mix.exs` file. However, this configuration is done
# automatically when you create the Phoenix application. See:
# https://youtu.be/160_O1ff6S4?si=WT6v6KzUkhd5MK7r&t=515

# NOTE ==>
# `DateTime.utc_now/0` generates decimals in seconds so it does not match what
# comes from `Ecto.changeset/2`, so you have to truncate the input parameters
# to seconds using `DateTime.truncate/2`:
# https://stackoverflow.com/questions/53717074/insert-all-does-not-match-type-utc-datetime#53718084
