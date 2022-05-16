defmodule ProductsManager.Services.Behaviours.RedixBehaviour do
  @type redis_command() :: [String.Chars.t()]
  @type connection() :: GenServer.server()
  @type handle_error :: :error | {:error, atom() | Redix.Error.t() | Redix.ConnectionError.t()}

  @callback command(connection(), redis_command()) ::
              {:ok, any}
              | handle_error

  @callback command(connection(), redis_command(), any) ::
              {:ok, any}
              | handle_error
end
