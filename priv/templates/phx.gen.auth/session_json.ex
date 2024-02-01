defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>SessionJSON do
  def error(%{message: message}) do
    %{error: message}
  end

  def create(%{token: token}) do
    %{access_token: token, token_type: "Bearer"}
  end

  def create(_), do: %{}
end
