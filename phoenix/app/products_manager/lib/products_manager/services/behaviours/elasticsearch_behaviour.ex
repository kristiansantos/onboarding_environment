defmodule ProductsManager.Services.Behaviours.ElasticsearchBehaviour do
  @callback get_all(any) :: :error | {:ok, list} | {:error, number, any} | {:ok, any}
  @callback get_all(any, list()) ::
              :error | {:ok, list} | {:error, number, any} | {:ok, any}
  @callback create_or_update(any, %{:id => any, optional(any) => any}) ::
              :error | {:error, number, any} | {:ok, number, any}
  @callback delete(any, any) :: :error | {:error, number, String.t()} | {:ok, number, any}
  @callback delete_all :: :error | {:error, number, String.t()} | {:ok, number, any}
end
