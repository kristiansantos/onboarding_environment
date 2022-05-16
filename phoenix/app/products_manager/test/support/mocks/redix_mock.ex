defmodule ProductsManager.RedixMock do
  use ExUnit.CaseTemplate

  @connection :redix_test

  using do
    quote do
      import Hammox

      defp redix_mock_command(status, command, data, attemps \\ 1) do
        expect(RedixBehaviourMock, :command, attemps, fn
          _, _ when command == "SET" and status == :ok -> {:ok, data}
          _, _ when command == "SET" and status == :error -> :error
          _, _ when command == "GET" and status == :ok -> {:ok, data}
          _, _ when command == "GET" and status == :error -> {:ok, nil}
          _, _ when command == "DEL" and status == :ok -> {:ok, data}
          _, _ when command == "DEL" and status == :error -> :error
        end)
      end
    end
  end
end
