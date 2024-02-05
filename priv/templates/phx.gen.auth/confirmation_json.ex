defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ConfirmationJSON do
  def error(%{message: message}) do
    %{error: message}
  end

  def create(%{message: message}) do
    %{message: message}
  end
end
