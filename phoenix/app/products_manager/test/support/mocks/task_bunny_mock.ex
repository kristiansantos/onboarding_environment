defmodule ProductsManager.TaskBunnyMock do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Hammox

      defp task_bunny_mock_enqueue(status, data, attemps \\ 1) do
        expect(TaskBunnyBehaviourMock, :enqueue, attemps, fn
          _, _ when status == :ok -> :ok
          _, _ when status == :error -> :error
        end)
      end

      defp task_bunny_mock_perfom(status, data, attemps \\ 1) do
        expect(TaskBunnyBehaviourMock, :enqueue, attemps, fn
          _ when status == :ok -> :ok
          _ when status == :error -> :error
        end)
      end
    end
  end
end
