defmodule ProductsManager.RedisMock do
  use ExUnit.CaseTemplate

  setup_all do
    Hammox.protect(ProductsManager.Services.Redis, RedisBehaviourMock)
  end

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
          :ok
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
