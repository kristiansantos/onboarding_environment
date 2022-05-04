defmodule ProductsManager.Services.Elasticsearch do
  @tirexs_http Application.get_env(:tirexs, :service)
  def get_all(source),
    do: handle_response(source, @tirexs_http.get("#{path()}/#{source}/_search"))

  def get_all(source, search_list),
    do:
      handle_response(
        source,
        @tirexs_http.get("#{path()}/#{source}/_search?q=#{convert_query(search_list)}")
      )

  def create_or_update(source, data),
    do: @tirexs_http.put("#{path()}/#{source}/#{data.id}", data)

  def delete(source, id), do: @tirexs_http.delete("#{path()}/#{source}/#{id}")
  def delete_all(), do: @tirexs_http.delete("#{path()}")

  defp convert_query(search_list) do
    search_list
    |> Enum.map_join("&", fn {key, value} -> "#{key}:#{value}" end)
    |> URI.encode()
  end

  defp handle_response(source, :error), do: {:error, :internal_server_error}

  defp handle_response(source, {:error, _http_code, _body} = error), do: error

  defp handle_response(source, {:ok, _, response}) do
    data =
      response[:hits][:hits]
      |> Enum.filter(fn key -> key[:_type] == source end)
      |> Enum.map(& &1[:_source])

    {:ok, data}
  end

  defp path() do
    Application.get_env(:elasticsearch, :index)
  end
end
