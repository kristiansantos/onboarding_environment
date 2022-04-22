defmodule ProductsManager.ElasticsearchMock do
  import Hammox

  use ExUnit.CaseTemplate

  use Hammox.Protect,
    module: ProductsManager.Services.Elasticsearch,
    behaviour: ProductsManager.Services.Behaviours.ElasticsearchBehaviour

  using do
    quote do
      defp elasticsearch_list_mock(:error, params, source) do
        if params == %{} do
          expect(ElasticsearchBehaviourMock, :get_all, fn source ->
            :error
          end)
        else
          expect(ElasticsearchBehaviourMock, :get_all, fn source, _ ->
            :error
          end)
        end
      end

      defp elasticsearch_list_mock(data \\ [], params, source) do
        if params == %{} do
          expect(ElasticsearchBehaviourMock, :get_all, fn source ->
            {:ok, data}
          end)
        else
          expect(ElasticsearchBehaviourMock, :get_all, fn source, _ ->
            {:ok, data}
          end)
        end
      end

      defp elasticsearch_create_update_mock(data \\ @valid_attrs) do
        expect(ElasticsearchBehaviourMock, :create_or_update, fn _, _ ->
          {:ok, 200, data}
        end)
      end

      defp elasticsearch_delete_mock(id, source) do
        expect(ElasticsearchBehaviourMock, :delete, fn source, id ->
          {:ok, 200, id}
        end)
      end
    end
  end
end
