defmodule ProductsManager.RedisMock do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Hammox

      defp redis_get_by_mock({:error, :not_found}) do
        expect(RedisBehaviourMock, :get_by, fn _, _ ->
          {:error, :not_found}
        end)
      end

      defp redis_get_by_mock(data) do
        expect(RedisBehaviourMock, :get_by, fn _, _ ->
          {:ok, data}
        end)
      end

      defp redis_set_mock(data) do
        expect(RedisBehaviourMock, :set, fn _, _ ->
          data
          |> :erlang.term_to_binary()
          |> Base.encode16()
        end)
      end

      defp redis_delete_mock(id, source) do
        expect(RedisBehaviourMock, :delete, fn id, source ->
          :ok
        end)
      end
    end
  end
end
