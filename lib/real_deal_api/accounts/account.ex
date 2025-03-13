defmodule RealDealApi.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealDealApi.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hash_password, :string
    has_one :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :hash_password])
    |> validate_required([:email, :hash_password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end
end

# REFERENCES:
# https://hexdocs.pm/ecto/associations.html#has-one-belongs-to

# Account.changeset(%Account{}, %{email: "hello@hello.com", hash_password: "353gsa"}) =>
# Ecto.Changeset<
# action: nil,
# changes: %{hash_password: "353gsa", email: "hello@hello"},
# errors: [],
# data: #RealDealApi.Accounts.Account<>,
# valid?: true,
# ...
# >
# Account.changeset(%Account{}, %{email: "hello.com", hash_password: "353gsa"}) =>
# Ecto.Changeset<
# action: nil,
# changes: %{hash_password: "353gsa", email: "hello.com"},
# errors: [email: {"must have the @ sign and no spaces", [validation: :format]}],
# data: #RealDealApi.Accounts.Account<>,
# valid?: false,
# ...
# >

# Manually creating an `Account` record in the database:
# Accounts.create_account(%{email: "backend@stuff.com", hash_password: "thisishash"}) ==>
# [debug] QUERY OK source="accounts" db=27.2ms decode=2.7ms queue=2.4ms idle=87.2ms
# INSERT INTO "accounts" ("email","hash_password","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5) ["backend@stuff.com", "thisishash", ~U[2025-03-13 19:06:27Z], ~U[2025-03-13 19:06:27Z], "04eb1664-c246-4af2-827c-de936e258e0b"]
# ↳ :elixir.eval_external_handler/3, at: src/elixir.erl:386
# {:ok,
#  %RealDealApi.Accounts.Account{
#    __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
#    id: "04eb1664-c246-4af2-827c-de936e258e0b",
#    email: "backend@stuff.com",
#    hash_password: "thisishash",
#    user: #Ecto.Association.NotLoaded<association :user is not loaded>,
#    inserted_at: ~U[2025-03-13 19:06:27Z],
#    updated_at: ~U[2025-03-13 19:06:27Z]
#  }}
