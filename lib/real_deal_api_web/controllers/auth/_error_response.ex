defmodule RealDealApiWeb.Auth.ErrorResponse.Unauthorized do
  defexception message: "Unauthorized", plug_status: 401
end

# ↑↑↑ Custom handling using exceptions ↑↑↑
# https://hexdocs.pm/phoenix/json_and_apis.html#action-fallback
# https://hexdocs.pm/phoenix/custom_error_pages.html
