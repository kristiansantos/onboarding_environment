defmodule ProductsManager.Services.RedisService do
  def get_by(id, source) do
    case Exredis.Api.get("#{source}:#{id}") do
      :undefined -> {:error, :not_found}
      binary -> {:ok, decode(binary)}
    end
  end

  def set(data, source) do
    Exredis.Api.set("#{source}:#{data.id}", encode(data))
  end

  def delete(id, source) do
    Exredis.Api.del("#{source}:#{id}")
  end

  def delete_all() do
    Exredis.Api.flushall()
  end

  defp encode(data), do: data |> :erlang.term_to_binary() |> Base.encode16()

  defp decode(data) do
    {_, result} = Base.decode16(data)
    :erlang.binary_to_term(result)
  end
end
