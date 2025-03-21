defmodule RealDealApiWeb.Auth.AuthorizedPlug do
  @moduledoc """
  This Plug acts as a `middleware` (passes through or throws an error).
  Prevents any user (even if authenticated) from updating or
  deleting another user's account.
  """

  alias RealDealApiWeb.Router

  def is_authorized(%{params: %{"account" => params}} = conn, _opts) do
    # We verify that the ID saved in the session is equal
    # to the one we receive in the parameters.
    case conn.assigns.account.id == params["id"] do
      true ->
        conn

      _ ->
        conn
        |> Router.handle_errors(%{
          reason: :forbidden,
          message: "You do not have access to this resource."
        })
    end
  end

  def is_authorized(%{params: %{"user" => params}} = conn, _opts) do
    case conn.assigns.account.user.id == params["id"] do
      true ->
        conn

      _ ->
        conn
        |> Router.handle_errors(%{
          reason: :forbidden,
          message: "You do not have access to this resource."
        })
    end
  end
end

# rescue
#   e in ArgumentError ->
#     conn
#     |> Router.handle_errors(%{
#       reason: :bad_request,
#       message: "ArgumentError: #{e.message}."
#     })

#   _e in Ecto.Query.CastError ->
#     conn
#     |> Router.handle_errors(%{
#       reason: :bad_request,
#       message: "Malformed input data."
#     })

#   _e in Ecto.NoResultsError ->
#     conn
#     |> Router.handle_errors(%{
#       reason: :not_found,
#       message: "There is no resource with that ID."
#     })
