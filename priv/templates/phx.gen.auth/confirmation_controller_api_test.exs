defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ConfirmationControllerTest do
  use <%= inspect context.web_module %>.ConnCase<%= test_case_options %>

  alias <%= inspect context.module %>
  alias <%= inspect schema.repo %>
  import <%= inspect context.module %>Fixtures

  setup do
    %{<%= schema.singular %>: <%= schema.singular %>_fixture()}
  end

  describe "POST <%= schema.api_route_prefix %>/confirm" do
    test "sends a new confirmation token", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/confirm", %{
          "<%= schema.singular %>" => %{"email" => <%= schema.singular %>.email}
        })

      %{"message" => message} = json_response(conn, 201)
      assert message =~ "If your email is in our system"

      assert Repo.get_by!(<%= inspect context.alias %>.<%= inspect schema.alias %>Token, <%= schema.singular %>_id: <%= schema.singular %>.id).context == "confirm"
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"<%= schema.api_route_prefix %>/confirm", %{
          "<%= schema.singular %>" => %{"email" => "unknown@example.com"}
        })

      %{"message" => message} = json_response(conn, 201)
      assert message =~ "If your email is in our system"

      assert Repo.all(<%= inspect context.alias %>.<%= inspect schema.alias %>Token) == []
    end
  end

  describe "POST <%= schema.api_route_prefix %>/confirm/:token" do
    test "confirms the given token once", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      token =
        extract_<%= schema.singular %>_token(fn url ->
          <%= inspect context.alias %>.deliver_<%= schema.singular %>_confirmation_instructions(<%= schema.singular %>, url)
        end)

      conn = post(conn, ~p"<%= schema.api_route_prefix %>/confirm/#{token}")
      %{"message" => message} = json_response(conn, 201)
      assert message == "<%= inspect schema.alias %> confirmed successfully."

      assert <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= schema.singular %>.id).confirmed_at
      assert Repo.all(<%= inspect context.alias %>.<%= inspect schema.alias %>Token) == []

      # When already confirmed
      conn = post(conn, ~p"<%= schema.api_route_prefix %>/confirm/#{token}")

      %{"error" => message} = json_response(conn, 400)
      assert message == "<%= inspect schema.alias %> confirmation link is invalid or it has expired."
    end

    test "does not confirm email with invalid token", %{conn: conn, <%= schema.singular %>: <%= schema.singular %>} do
      conn = post(conn, ~p"<%= schema.api_route_prefix %>/confirm/oops")

      %{"error" => message} = json_response(conn, 400)
      assert message == "<%= inspect schema.alias %> confirmation link is invalid or it has expired."

      refute <%= inspect context.alias %>.get_<%= schema.singular %>!(<%= schema.singular %>.id).confirmed_at
    end
  end
end
