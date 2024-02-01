defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>SessionController do
  use <%= inspect context.web_module %>, :controller

  alias <%= inspect context.module %>

  action_fallback <%= inspect context.web_module %>.FallbackController

  def create(conn, %{"<%= schema.singular %>" => <%= schema.singular %>_params}) do
    %{"email" => email, "password" => password} = <%= schema.singular %>_params

    if <%= schema.singular %> = <%= inspect context.alias %>.get_<%= schema.singular %>_by_email_and_password(email, password) do
      token = <%= inspect context.alias %>.create_<%= schema.singular %>_api_token(<%= schema.singular %>)

      conn
      |> put_status(:created)
      |> render(:create, %{token: token})
    else
      conn
      |> put_status(:unauthorized)
      |> render(:error, message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    ["Bearer " <> token] = get_req_header(conn, "authorization")
    <%= inspect context.alias %>.delete_<%= schema.singular %>_api_token(token)

    conn
    |> put_status(:ok)
    |> render(:create)
  end
end
