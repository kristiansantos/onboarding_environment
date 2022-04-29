defmodule ProductsManager.Services.Elasticsearch do
  @tirexs_http Application.get_env(:tirexs, :service)

  def get_all(source) do
    with {:ok, 200, response_body} <- @tirexs_http.get("#{path()}/#{source}/_search") do
      {:ok, response_format(response_body[:hits][:hits], source)}
    end
  end

  def get_all(source, array_conditions) do
    with {:ok, 200, response_body} <-
           @tirexs_http.get("#{path()}/#{source}/_search?q=#{convert_query(array_conditions)}") do
      {:ok, response_format(response_body[:hits][:hits], source)}
    end
  end

  def create_or_update(source, data) do
    @tirexs_http.put("#{path()}/#{source}/#{data.id}", convert_data(data))
  end

  def delete(source, id) do
    @tirexs_http.delete("#{path()}/#{source}/#{id}")
  end

  def delete_all() do
    @tirexs_http.delete("#{path()}")
  end

  defp convert_data(data) do
    data
    |> Map.drop([:__meta__, :__struct__])
    |> Map.put(:updated_at, DateTime.to_iso8601(DateTime.utc_now()))
    |> Map.to_list()
  end

  defp convert_query(array_conditions) do
    Enum.map_join(array_conditions, "&", fn {key, value} -> "#{key}:#{value}" end)
  end

  defp response_format(response, source) do
    response
    |> Enum.filter(fn key -> key[:_type] == source end)
    |> Enum.map(fn key -> Map.delete(key[:_source], :updated_at) end)
  end

  defp path() do
    Application.get_env(:elasticsearch, :index)
  end
end
