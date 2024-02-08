defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ResetPasswordJSON do
  def show(%{message: message}) do
    %{message: message}
  end

  def error(%{message: message}) do
    %{error: message}
  end
end
