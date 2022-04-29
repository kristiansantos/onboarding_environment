defmodule ProductsManager.RedixMock do
  use ExUnit.CaseTemplate

  @connection :redix_test

  setup_all do
    Hammox.protect(Redix, RedixBehaviourMock)
  end

  using do
    quote do
      import Hammox

      defp redix_mock_command(status, command, data, attemps \\ 1) do
        expect(RedixBehaviourMock, :command, attemps, fn
          _, _ when status == :ok -> {:ok, data}
          _, _ when status == :error -> {:ok, nil}
        end)
      end

      defp redix_mock_command(status, command, data, attemps, opts) do
        expect(RedixBehaviourMock, :command, attemps, fn _, _, _ ->
          {:ok, data}
        end)
      end
    end
  end
end
