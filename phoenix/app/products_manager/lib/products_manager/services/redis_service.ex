defmodule ProductsManager.Services.RedisService do
  @conn :redis_connection

  @redix Application.get_env(:redix, :lib)

  def get_by(source, id) do
    case @redix.command(@conn, ["GET", "#{source}:#{id}"]) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, response} -> {:ok, decode(response)}
      {:error, _reason} -> :error
    end
  end

  def set(source, data) do
    case @redix.command(@conn, ["SET", "#{source}:#{data.id}", encode(data)]) do
      {:ok, _response} -> :ok
      {:error, _reason} -> :error
    end
  end

  def set_expire(source, data, expire_seconds) do
    case @redix.command(@conn, ["SET", "#{source}:#{data.id}", encode(data), "EX", expire_seconds]) do
      {:ok, _response} -> :ok
      {:error, _reason} -> :error
    end
  end

  def delete(source, id) do
    case @redix.command(@conn, ["DEL", "#{source}:#{id}"]) do
      {:ok, _response} -> :ok
      {:error, _reason} -> :error
    end
  end

  def delete_all() do
    case @redix.command(@conn, ["FLUSHDB"]) do
      {:ok, _response} -> :ok
      {:error, _reason} -> :error
    end
  end

  defp encode(data), do: data |> :erlang.term_to_binary() |> Base.encode16()

  defp decode(data) when is_binary(data) do
    with {_, result} <- Base.decode16(data) do
      :erlang.binary_to_term(result)
    end
  end

  defp decode(data), do: data
end
