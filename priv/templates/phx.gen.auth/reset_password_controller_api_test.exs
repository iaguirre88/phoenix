defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ResetPasswordControllerTest do
  use <%= inspect context.web_module %>.ConnCase<%= test_case_options %>

  alias <%= inspect context.module %>
  alias <%= inspect schema.repo %>
  import <%= inspect context.module %>Fixtures

  setup do
    %{<%= schema.singular %>: <%= schema.singular %>_fixture()}
  end

  describe "POST <%= schema.api_route_prefix %>/reset_password" do
    test "sends a new reset password token", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/reset_password", %{
          "<%= schema.singular %>" => %{"email" => <%= schema.singular %>.email}
        })

      assert json_response(conn, 201)["message"] =~ "If your email is in our system"
      assert Repo.get_by!(<%= inspect context.alias %>.<%= inspect schema.alias %>Token, <%= schema.singular %>_id: <%= schema.singular %>.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/reset_password", %{
          "<%= schema.singular %>" => %{"email" => "unknown@example.com"}
        })

      assert json_response(conn, 201)["message"] =~ "If your email is in our system"
      assert Repo.all(<%= inspect context.alias %>.<%= inspect schema.alias %>Token) == []
    end
  end

  describe "PUT <%= schema.api_route_prefix %>/reset_password/:token" do
    setup %{<%= schema.singular %>: <%= schema.singular %>} do
      token =
        extract_<%= schema.singular %>_token(fn url ->
          <%= inspect context.alias %>.deliver_<%= schema.singular %>_reset_password_instructions(<%= schema.singular %>, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>, token: token} do
      conn =
        put(conn, ~p"<%= schema.api_route_prefix %>/reset_password/#{token}", %{
          "<%= schema.singular %>" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert json_response(conn, 200)["message"] == "Password reset successfully."
      assert <%= inspect context.alias %>.get_<%= schema.singular %>_by_email_and_password(<%= schema.singular %>.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, ~p"<%= schema.api_route_prefix %>/reset_password/#{token}", %{
          "<%= schema.singular %>" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

        assert json_response(conn, 422)["errors"] == %{
          "password" => ["should be at least 12 character(s)"],
          "password_confirmation" => ["does not match password"]
        }
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, ~p"<%= schema.api_route_prefix %>/reset_password/oops")

      assert json_response(conn, 422)["error"] ==
        "Reset password link is invalid or it has expired."
    end
  end
end
