defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ResetPasswordController do
  use <%= inspect context.web_module %>, :controller

  alias <%= inspect context.module %>

  action_fallback <%= inspect context.web_module %>.FallbackController

  plug :get_<%= schema.singular %>_by_reset_password_token when action in [:update]

  def create(conn, %{"<%= schema.singular %>" => %{"email" => email}}) do
    if <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>_by_email(email) do
      <%= inspect context.alias %>.deliver_<%= schema.singular %>_reset_password_instructions(
        <%= schema.singular %>,
        &url(~p"<%= schema.route_prefix %>/reset_password/#{&1}")
      )
    end

    conn
    |> put_status(:created)
    |> render(:show, %{
      message:
        "If your email is in our system, you will receive instructions to reset your password shortly."
    })
  end

  # Do not log in the <%= schema.singular %> after reset password to avoid a
  # leaked token giving the <%= schema.singular %> access to the account.
  def update(conn, %{"<%= schema.singular %>" => <%= schema.singular %>_params}) do
    with {:ok, _user} <- <%= inspect context.alias %>.reset_<%= schema.singular %>_password(conn.assigns.<%= schema.singular %>, <%= schema.singular %>_params) do
      conn
      |> put_status(:ok)
      |> render(:show, %{message: "Password reset successfully."})
    end
  end

  defp get_<%= schema.singular %>_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>_by_reset_password_token(token) do
      conn |> assign(:<%= schema.singular %>, <%= schema.singular %>) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
