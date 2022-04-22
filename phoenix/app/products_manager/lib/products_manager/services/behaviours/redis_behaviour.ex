defmodule ProductsManager.Services.Behaviours.RedisBehaviour do
  @callback get_by(any, any) ::
              {:ok, any}
              | {:error,
                 atom
                 | %{
                     :__exception__ => any,
                     :__struct__ => Redix.ConnectionError | Redix.Error,
                     optional(:message) => binary,
                     optional(:reason) => atom
                   }}
  @callback set(any, any) ::
              :ok
              | {:error,
                 atom
                 | %{
                     :__exception__ => any,
                     :__struct__ => Redix.ConnectionError | Redix.Error,
                     optional(:message) => binary,
                     optional(:reason) => atom
                   }}
  @callback delete(any, any) ::
              :ok
              | {:error,
                 atom
                 | %{
                     :__exception__ => any,
                     :__struct__ => Redix.ConnectionError | Redix.Error,
                     optional(:message) => binary,
                     optional(:reason) => atom
                   }}
  @callback delete_all ::
              :ok
              | {:error,
                 atom
                 | %{
                     :__exception__ => any,
                     :__struct__ => Redix.ConnectionError | Redix.Error,
                     optional(:message) => binary,
                     optional(:reason) => atom
                   }}
end
