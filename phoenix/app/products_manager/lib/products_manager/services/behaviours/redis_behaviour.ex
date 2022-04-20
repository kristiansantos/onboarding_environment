defmodule ProductsManager.Services.Behaviours.RedisBehaviour do
  @callback get_by(any, any) :: {:error, :not_found} | {:ok, any}
  @callback set(atom | %{:id => any, optional(any) => any}, any) ::
              :no_connection | :ok | :undefined | binary | [binary | [...]]
  @callback delete(any, any) :: any
  @callback delete_all :: :no_connection | :ok | :undefined | binary | [binary | [...]]
end
