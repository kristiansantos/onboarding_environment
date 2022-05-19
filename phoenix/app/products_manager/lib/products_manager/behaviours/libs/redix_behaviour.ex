defmodule ProductsManager.Behaviours.Libs.RedixBehaviour do
  @type redis_command() :: [String.Chars.t()]
  @type connection() :: GenServer.server()
  @type handle_error :: :error | {:error, any()}

  @callback command(connection(), redis_command()) ::
              {:ok, any}
              | handle_error

  @callback command(connection(), redis_command(), any) ::
              {:ok, any}
              | handle_error
end
