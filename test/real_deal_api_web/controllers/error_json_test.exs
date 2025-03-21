defmodule RealDealApiWeb.ErrorJSONTest do
  use RealDealApiWeb.ConnCase, async: true

  test "renders 404" do
    assert RealDealApiWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "There is no resource with that ID."}
           }

    # {detail: "Not Found"}}
  end

  test "renders 500" do
    assert RealDealApiWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
