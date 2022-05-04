defmodule ProductsManager.TirexsHttpMock do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Hammox

      defp tirexs_mock_get(attemps \\ 1, status, data) do
        expect(TirexsHttpBehaviourMock, :get, attemps, fn
          _ when status == :ok and data == [] -> elasticsearch_get_response()
          _ when status == :ok and data != [] -> elasticsearch_get_response(data)
          _ when status == :error -> :error
        end)
      end

      defp tirexs_mock_put(attemps \\ 1) do
        expect(TirexsHttpBehaviourMock, :put, attemps, fn _, _ ->
          {:ok, 201, %{}}
        end)
      end

      defp tirexs_mock_delete(attemps \\ 1) do
        expect(TirexsHttpBehaviourMock, :delete, attemps, fn _ ->
          {:ok, 201, %{}}
        end)
      end

      defp elasticsearch_get_response() do
        {:ok, 200,
         %{
           hits: %{
             hits: []
           }
         }}
      end

      defp elasticsearch_get_response(data) do
        {:ok, 200,
         %{
           hits: %{
             hits: [
               %{
                 _id: data.id,
                 _index: "products_manager",
                 _score: 1.0,
                 _source: data,
                 _type: "product"
               }
             ]
           }
         }}
      end
    end
  end
end
