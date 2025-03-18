defmodule RealDealApiWeb.Router do
  use RealDealApiWeb, :router
  use Plug.ErrorHandler

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  def handle_errors(conn, %{reason: reason, message: message}) do
    conn |> put_status(reason) |> json(%{errors: message}) |> halt()
  end

  # See: `Custom handling using exceptions`
  # https://hexdocs.pm/phoenix/json_and_apis.html#action-fallback
  # https://hexdocs.pm/phoenix/custom_error_pages.html

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :auth do
    plug RealDealApiWeb.Auth.Pipeline
    plug RealDealApiWeb.Auth.SetAccount
  end

  scope "/api", RealDealApiWeb do
    pipe_through :api

    get "/", DefaultController, :index

    post "/accounts/create", AccountController, :create
    post "/accounts/sign_in", AccountController, :sign_in

    # resources "/accounts", AccountController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]
  end

  # Routes protected by JWT.
  scope "/api", RealDealApiWeb do
    pipe_through [:api, :auth]

    get "/accounts/by_id/:id", AccountController, :show
    patch "/accounts/update", AccountController, :update
  end
end

# API routes:
# mix phx.routes | grep accounts ==>
# GET     /api/accounts      RealDealApiWeb.AccountController :index
# GET     /api/accounts/:id  RealDealApiWeb.AccountController :show
# POST    /api/accounts      RealDealApiWeb.AccountController :create
# PATCH   /api/accounts/:id  RealDealApiWeb.AccountController :update
# PUT     /api/accounts/:id  RealDealApiWeb.AccountController :update
# DELETE  /api/accounts/:id  RealDealApiWeb.AccountController :delete

# # Discard all changes:
# https://stackoverflow.com/questions/1146973/how-do-i-revert-all-local-changes-in-git-managed-project-to-previous-state
# https://gist.github.com/khoa-le/03c4de439125f969e03d
# To remove untracked files & directories
# git clean -fd
# git checkout .
# https://hexdocs.pm/ecto_sql/Mix.Tasks.Ecto.Rollback.html
# mix ecto.rollback
# mix ecto.rollback -r Custom.Repo

# mix ecto.rollback -n 3
# mix ecto.rollback --step 3

# e.g:
# mix ecto.rollback --to 20080906120000

# Testing the path: post "/accounts", AccountController, :create
# {
# 	"account": {
# 		"email": "client1@realdealapi.com",
# 		"hash_password": "real_password",
# 		"full_name": "Blork Erlang",
# 		"gender": "null",
# 		"biography": "null"
# 	}
# } ==>
# {
# 	"data": {
# 		"id": "f3e41f5a-16ad-465d-a287-6142d774d69c",
# 		"token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJyZWFsX2RlYWxfYXBpIiwiZXhwIjoxNzQ0Mzg5ODI4LCJpYXQiOjE3NDE5NzA2MjgsImlzcyI6InJlYWxfZGVhbF9hcGkiLCJqdGkiOiJjYjBhZjhlZi05MTUwLTQ4ZTgtYjNhMS02MzIxZDk0OTI2ZDIiLCJuYmYiOjE3NDE5NzA2MjcsInN1YiI6ImYzZTQxZjVhLTE2YWQtNDY1ZC1hMjg3LTYxNDJkNzc0ZDY5YyIsInR5cCI6ImFjY2VzcyJ9.IRaWzz1PBf8RUBxAmmLSUb4OlkHEkm_YEAuyyOhJAJPMb6u4aj5lYatmZdD8QUttfiHYWoM4cvHHCM8-XT-JEQ",
# 		"email": "client1@realdealapi.com"
# 	}
# }
