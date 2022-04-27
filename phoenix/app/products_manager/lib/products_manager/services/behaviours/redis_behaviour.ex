defmodule ProductsManager.Services.Behaviours.RedisBehaviour do
  @type method_result :: {:ok, any} | :ok
  @type handle_error ::
          {:error,
           atom
           | %{
               :__exception__ => any,
               :__struct__ => Redix.ConnectionError | Redix.Error,
               optional(:message) => binary,
               optional(:reason) => atom
             }}

  @callback get_by(String.t(), String.t()) :: method_result | handle_error
  @callback set(String.t(), map()) :: method_result | handle_error
  @callback delete(String.t(), String.t()) :: method_result | handle_error
  @callback delete_all :: method_result | handle_error
end
