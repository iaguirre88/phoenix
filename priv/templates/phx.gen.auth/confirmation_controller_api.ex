defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ConfirmationController do
  use <%= inspect context.web_module %>, :controller

  alias <%= inspect context.module %>

  action_fallback <%= inspect context.web_module %>.FallbackController

  def create(conn, %{"<%= schema.singular %>" => %{"email" => email}}) do
    if <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>_by_email(email) do
      <%= inspect context.alias %>.deliver_<%= schema.singular %>_confirmation_instructions(
        <%= schema.singular %>,
        &url(~p"<%= schema.api_route_prefix %>s/confirm/#{&1}")
      )
    end

    conn
    |> put_status(:created)
    |> render(:create, %{
      message:
        "If your email is in our system and it has not been confirmed yet, " <>
          "you will receive an email with instructions shortly."
    })
  end

  # Do not log in the <%= schema.singular %> after confirmation to avoid a
  # leaked token giving the <%= schema.singular %> access to the account.
  def update(conn, %{"token" => token}) do
    case <%= inspect context.alias %>.confirm_<%= schema.singular %>(token) do
      {:ok, _} ->
        conn
        |> put_status(:created)
        |> render(:create, %{message: "<%= schema.human_singular %> confirmed successfully."})

      :error ->
        conn
        |> put_status(:bad_request)
        |> render(:error, %{message: "<%= schema.human_singular %> confirmation link is invalid or it has expired."})
    end
  end
end
