defmodule RealDealApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use RealDealApiWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: RealDealApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> put_view(html: RealDealApiWeb.ErrorHTML, json: RealDealApiWeb.ErrorJSON)
    |> render(:"400")
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: RealDealApiWeb.ErrorHTML, json: RealDealApiWeb.ErrorJSON)
    |> render(:"404")
  end

  # This clause handles the `account` resource when your email or password
  # does not match what is stored in the DB ==> `status 401 unauthorized`
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(html: RealDealApiWeb.ErrorHTML, json: RealDealApiWeb.ErrorJSON)
    |> render(:"401")
  end
end
