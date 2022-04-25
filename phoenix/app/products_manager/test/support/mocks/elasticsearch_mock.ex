defmodule ProductsManager.ElasticsearchMock do
  import Hammox

  use ExUnit.CaseTemplate

  setup_all do
    Hammox.protect(ProductsManager.Services.Elasticsearch, ElasticsearchBehaviourMock)
  end

  using do
    quote do
      defp elasticsearch_list_mock(:no_search, status, data \\ [], source) do
        expect(ElasticsearchBehaviourMock, :get_all, fn
          source when status == :error -> :error
          source when status == :ok -> {:ok, data}
        end)
      end

      defp elasticsearch_list_mock(:search, status, data, source) do
        expect(ElasticsearchBehaviourMock, :get_all, fn
          source, _ when status == :error -> :error
          source, _ when status == :ok -> {:ok, data}
        end)
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
