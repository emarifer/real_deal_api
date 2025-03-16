defmodule RealDealApiWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".

  def render("401.json", _assigns) do
    %{errors: %{detail: "Email or Password incorrect."}}
  end

  # ↑↑↑ Custom message. If not customized, Phoenix will return ↑↑↑
  # the error message corresponding to the status
  # (in this case, 'Unauthorized'): ==>
  # {
  #   "errors": {
  #     "detail": "Unauthorized"
  #   }
  # }
  # IMPORTANT: To match and not render the default Phoenix HTML template,
  # these `render` functions must be placed above the one that
  # renders the HTML template.

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
