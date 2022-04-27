defmodule ProductsManager.Services.Behaviours.ElasticsearchBehaviour do
  @type method_result :: {:ok, list} | {:ok, any} | {:ok, number, any}
  @type handle_error :: :error | {:error, number, any}

  @callback get_all(String.t()) :: method_result | handle_error
  @callback get_all(String.t(), list()) :: method_result | handle_error
  @callback create_or_update(String.t(), %{:id => any, optional(any) => any}) ::
              method_result | handle_error
  @callback delete(String.t(), String.t()) :: method_result | handle_error
  @callback delete_all :: method_result | handle_error
end
