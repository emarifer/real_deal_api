defmodule RealDealApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealDealApi.Accounts.Account

  @optional_fields [:id, :full_name, :gender, :biography, :inserted_at, :updated_at]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :full_name, :string
    field :gender, :string
    field :biography, :string
    belongs_to :account, Account

    timestamps(type: :utc_datetime)
  end

  # see note below.
  def all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
  end
end

# REFERENCES:
# https://neon.tech/postgresql/postgresql-tutorial/postgresql-delete-cascade
# https://hexdocs.pm/ecto/associations.html#has-one-belongs-to
