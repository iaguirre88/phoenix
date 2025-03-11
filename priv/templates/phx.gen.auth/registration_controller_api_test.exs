defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>RegistrationControllerTest do
  use <%= inspect context.web_module %>.ConnCase<%= test_case_options %>

  describe "POST <%= schema.api_route_prefix %>/register" do
    test "creates account and logs the <%= schema.singular %> in when data is valid", %{conn: conn} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/register",
          <%= schema.singular %>: %{email: "test@example.com", password: "this_is_a_password"}
        )

      %{"access_token" => access_token, "token_type" => token_type} = json_response(conn, 201)

      {:ok, <%= schema.singular %>} = <%= inspect context.module %>.fetch_<%= schema.singular %>_by_api_token(access_token)

      assert token_type == "Bearer"
      assert <%= schema.singular %>.email == "test@example.com"
    end

    test "returns error for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/register", <%= schema.singular %>: %{email: "with spaces", "too short"})

      assert json_response(conn, 422)["errors"] == %{
               "email" => ["must have the @ sign and no spaces"],
               "password" => ["should be at least 12 character(s)"]
             }
    end
  end
end
