defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>RegistrationJSON do
  def create(%{token: token}) do
    %{access_token: token, token_type: "Bearer"}
  end
end
