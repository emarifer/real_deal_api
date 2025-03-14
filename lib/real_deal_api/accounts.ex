defmodule RealDealApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RealDealApi.Repo

  alias RealDealApi.Accounts.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Gets a single account [account.any()] by given email.

  Returns 'nil' if the Account does not exist.

   ## Examples

     iex> get_account_by_email(test@email.com)
     %Account{}

     iex> get_account_by_email(no_account@email.com)
     nil

  """
  def get_account_by_email(email) do
    # ↓↓↓ This is like an interpolation in the SQL query string. ↓↓↓
    Account
    |> where(email: ^email)
    |> Repo.one()
  end

  # ↑↑↑ Using the pin operator (^) in the `where` function. ↑↑↑
  # If not used, Elixir will throw an error:
  # "(Ecto.Query.CompileError) unbound variable `email` in query.
  # If you are attempting to interpolate a value, use ^var Elixir".
  # The pin operator (`^`) ensures that the `email` in the `where` clause
  # matches the specific value passed to the function; without it,
  # Elixir would treat `email` as a new variable in the query,
  # leading to incorrect or unintended behavior. This happens because
  # the `where` function takes a keywords list and needs to bind
  # the value passed to the keyword list function.
  # https://hexdocs.pm/ecto/Ecto.Query.html#where/3
  # https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%5E/1

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end

# Testing account creation and authentication with JWT (login):
# Create an Accout:
# Accounts.create_account(%{email: "first_account@test.com", hash_password: "our_password"})
# [debug] QUERY OK source="accounts" db=27.3ms decode=3.3ms queue=2.2ms idle=1135.3ms
# INSERT INTO "accounts" ("email","hash_password","inserted_at","updated_at","id") VALUES ($1,$2,$3,$4,$5) ["first_account@test.com", "$2b$12$vezWYHfWDUWdorYvHVWA6eiNy6wz2ZlZvxNWy4JEzXZ/I7aGckZHW", ~U[2025-03-14 11:23:45Z], ~U[2025-03-14 11:23:45Z], "4d7a53be-6147-428c-b7ad-87527bd27a34"]
# ↳ :elixir.eval_external_handler/3, at: src/elixir.erl:386
# {:ok,
#  %RealDealApi.Accounts.Account{
#    __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
#    id: "4d7a53be-6147-428c-b7ad-87527bd27a34",
#    email: "first_account@test.com",
#    hash_password: "$2b$12$vezWYHfWDUWdorYvHVWA6eiNy6wz2ZlZvxNWy4JEzXZ/I7aGckZHW",
#    user: #Ecto.Association.NotLoaded<association :user is not loaded>,
#    inserted_at: ~U[2025-03-14 11:23:45Z],
#    updated_at: ~U[2025-03-14 11:23:45Z]
#  }}

# Authenticate & Get JWT:
# RealDealApiWeb.Auth.Guardian.authenticate("first_account@test.com", "our_password")
# [debug] QUERY OK source="accounts" db=1.8ms queue=5.2ms idle=1994.3ms
# SELECT a0."id", a0."email", a0."hash_password", a0."inserted_at", a0."updated_at" FROM "accounts" AS a0 WHERE (a0."email" = $1) ["first_account@test.com"]
# ↳ RealDealApiWeb.Auth.Guardian.authenticate/2, at: lib/real_deal_api_web/controllers/auth/guardian.ex:35
# {:ok,
#  %RealDealApi.Accounts.Account{
#    __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
#    id: "4d7a53be-6147-428c-b7ad-87527bd27a34",
#    email: "first_account@test.com",
#    hash_password: "$2b$12$vezWYHfWDUWdorYvHVWA6eiNy6wz2ZlZvxNWy4JEzXZ/I7aGckZHW",
#    user: #Ecto.Association.NotLoaded<association :user is not loaded>,
#    inserted_at: ~U[2025-03-14 11:23:45Z],
#    updated_at: ~U[2025-03-14 11:23:45Z]
#  },
#  "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJyZWFsX2RlYWxfYXBpIiwiZXhwIjoxNzQ0MzcxMjQ5LCJpYXQiOjE3NDE5NTIwNDksImlzcyI6InJlYWxfZGVhbF9hcGkiLCJqdGkiOiJiM2NhODZlNy02OWU3LTRjYmQtODg1My1lNDk0NGNkZTJiMGUiLCJuYmYiOjE3NDE5NTIwNDgsInN1YiI6IjRkN2E1M2JlLTYxNDctNDI4Yy1iN2FkLTg3NTI3YmQyN2EzNCIsInR5cCI6ImFjY2VzcyJ9.lq758oPaRkr9X7XXhKkxy9hOAQNglSmm5SY1htZER5XrFHuqO6KO6wH44ORTnDZIFtDCKhngWOUXGcrTbKOPcA"}

# Validating and inspecting the JWT at https://jwt.io/ :
# secret_key: "eUn5rc3c7LozyE9B7sZPZWh+ZHse4Tv8ti0/9ZZH7Lz2jjpsltSAAmYT38p4+YU2"
# ↑↑↑ from config.exs ↑↑↑
# Results:
# Decoded Header:
# {
#   "alg": "HS512",
#   "typ": "JWT"
# }
# Decoded Payload:
# {
#   "aud": "real_deal_api",
#   "exp": 1744371249, ==> (Fri Apr 11 2025 13:34:09 GMT+0200 (hora de verano de Europa central))
#   "iat": 1741952049, ==> (Fri Mar 14 2025 12:34:09 GMT+0100 (hora estándar de Europa central))
#   "iss": "real_deal_api",
#   "jti": "b3ca86e7-69e7-4cbd-8853-e4944cde2b0e",
#   "nbf": 1741952048,
#   "sub": "4d7a53be-6147-428c-b7ad-87527bd27a34",
#   "typ": "access"
# }
# Secret: => valid secret
# eUn5rc3c7LozyE9B7sZPZWh+ZHse4Tv8ti0/9ZZH7Lz2jjpsltSAAmYT38p4+YU2
