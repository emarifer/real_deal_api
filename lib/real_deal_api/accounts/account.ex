defmodule RealDealApi.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealDealApi.Users.User

  @optional_fields [:id, :inserted_at, :updated_at]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hash_password, :string
    has_one :user, User

    timestamps(type: :utc_datetime)
  end

  # see note below.
  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  # Encryption of the password if the previous validations are passed,
  # otherwise it does not hash the password.
  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{hash_password: hash_password}} = changeset
       ) do
    change(changeset, hash_password: Bcrypt.hash_pwd_salt(hash_password))
  end

  defp put_password_hash(changeset), do: changeset
end

# REFERENCES:
# https://neon.tech/postgresql/postgresql-tutorial/postgresql-delete-cascade
# https://hexdocs.pm/ecto/associations.html#has-one-belongs-to

# NOTE:
# Trick to add more fields "dynamically" to the schema using
# an `all_fields/0` function and a module attribute (@optional_fields):
# https://youtu.be/RZLuB4vGPJI?si=v8j6Ji-ewjoAuzpG&t=171
# "Reflection: Any schema module will generate the __schema__ function
# ↓↓↓ that can be used for runtime introspection of the schema." ↓↓↓
# https://hexdocs.pm/ecto/Ecto.Schema.html#module-reflection

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

# Bcrypt examples: https://hexdocs.pm/bcrypt_elixir/Bcrypt.html#hash_pwd_salt/2-examples ==>
# hash = Bcrypt.hash_pwd_salt("password")
# Bcrypt.verify_pass("password", hash)
# true

# hash = Bcrypt.hash_pwd_salt("password")
# Bcrypt.verify_pass("incorrect", hash)
# false

# Generating a struct `Ecto.Changeset` using the `changeset`
# function with the password hashed using the `put_password_hash` function:
# Account.changeset(%Account{}, %{email: "hello@hello.com", hash_password: "password"})
# Ecto.Changeset<
# action: nil,
# changes: %{
#   email: "hello@hello.com",
#   hash_password: "$2b$12$NIsa0A5082tKBpM4WRhat.K8T8t98puyuX5RfzsWgffPn0sm7C5K2"
# },
# errors: [],
# data: #RealDealApi.Accounts.Account<>,
# valid?: true,
# ...
# >
