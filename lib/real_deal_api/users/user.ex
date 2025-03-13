defmodule RealDealApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealDealApi.Accounts.Account

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :full_name, :string
    field :gender, :string
    field :biography, :string
    belongs_to :account, Account

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:account_id, :full_name, :gender, :biography])
    |> validate_required([:account_id])
  end
end

# REFERENCES:
# https://hexdocs.pm/ecto/associations.html#has-one-belongs-to
