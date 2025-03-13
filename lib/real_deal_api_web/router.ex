defmodule RealDealApiWeb.Router do
  use RealDealApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RealDealApiWeb do
    pipe_through :api

    get "/", DefaultController, :index

    resources "/accounts", AccountController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]
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
