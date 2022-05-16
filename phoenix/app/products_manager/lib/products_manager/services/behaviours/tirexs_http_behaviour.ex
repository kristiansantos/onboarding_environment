defmodule ProductsManager.Services.Behaviours.TirexsHttpBehaviour do
  @type method_result :: {:ok, number, any}
  @type handle_error :: :error | {:error, number, any}

  @callback get(binary | URI.t()) :: method_result | handle_error
  @callback put(binary | URI.t(), any) :: method_result | handle_error
  @callback delete(binary | URI.t()) :: method_result | handle_error
end
