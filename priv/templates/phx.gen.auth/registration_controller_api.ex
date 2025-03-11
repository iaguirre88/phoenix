defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>RegistrationController do
  use <%= inspect context.web_module %>, :controller

  alias <%= inspect context.module %>

  action_fallback <%= inspect context.web_module %>.FallbackController

  def create(conn, %{"<%= schema.singular %>" => <%= schema.singular %>_params}) do
    case <%= inspect context.alias %>.register_<%= schema.singular %>(<%= schema.singular %>_params) do
      {:ok, <%= schema.singular %>} ->
        # TODO: check if we need to send the login instuctions
        {:ok, _} =
          <%= inspect context.alias %>.deliver_<%= schema.singular %>_login_instructions(
            <%= schema.singular %>,
            &url(~p"<%= schema.api_route_prefix %>/log-in/#{&1}")
          )

        token = <%= inspect context.alias %>.create_<%= schema.singular %>_api_token(<%= schema.singular %>)

        conn
        |> put_status(:created)
        |> render(:create, %{token: token})
    end
  end
end
