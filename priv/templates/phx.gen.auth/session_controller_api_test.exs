defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>SessionControllerTest do
  use <%= inspect context.web_module %>.ConnCase<%= test_case_options %>

  import <%= inspect context.module %>Fixtures

  setup do
    %{<%= schema.singular %>: <%= schema.singular %>_fixture()}
  end

  describe "POST <%= schema.api_route_prefix %>/log_in" do
    test "logs the <%= schema.singular %> in", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/log_in", %{
          <%= schema.singular %>: %{email: <%= schema.singular %>.email, password: valid_<%= schema.singular %>_password()}
        })

      %{"access_token" => access_token} = json_response(conn, 201)
      {:ok, logged_<%= schema.singular %>} = <%= inspect context.module %>.fetch_<%= schema.singular %>_by_api_token(access_token)

      assert <%= schema.singular %>.email == logged_<%= schema.singular %>.email
    end

    test "emits error message with invalid credentials", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/log_in", %{
          <%= schema.singular %>: %{email: <%= schema.singular %>.email, password: "invalid_password"}
        })

      %{"error" => error} = json_response(conn, 401)
      assert error == "Invalid email or password"
    end
  end

  describe "DELETE <%= schema.api_route_prefix %>/log_out" do
    test "logs the <%= schema.singular %> out", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      login_conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/log_in", %{
          <%= schema.singular %>: %{email: <%= schema.singular %>.email, password: valid_<%= schema.singular %>_password()}
        })

      %{"access_token" => access_token} = json_response(login_conn, 201)
      {:ok, logged_<%= schema.singular %>} = <%= inspect context.module %>.fetch_<%= schema.singular %>_by_api_token(access_token)
      assert <%= schema.singular %>.email == logged_<%= schema.singular %>.email

      delete_conn = put_req_header(conn, "authorization", "Bearer #{access_token}")
      delete_conn = delete(delete_conn, ~p"<%= schema.api_route_prefix %>/log_out")

      assert %{} == json_response(delete_conn, 200)
      assert :error == <%= inspect context.module %>.fetch_<%= schema.singular %>_by_api_token(access_token)
    end

    test "succeeds even if the <%= schema.singular %> is not logged in", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Bearer access_token")
      conn = delete(conn, ~p"<%= schema.api_route_prefix %>/log_out")

      assert %{} == json_response(conn, 200)
    end
  end
end
