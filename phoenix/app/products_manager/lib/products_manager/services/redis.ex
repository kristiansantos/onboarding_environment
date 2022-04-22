defmodule ProductsManager.Services.Redis do
  @conn :redis_connection

  @behaviour ProductsManager.Services.Behaviours.RedisBehaviour
  def get_by(source, id) do
    case Redix.command(@conn, ["GET", "#{source}:#{id}"]) do
      {:error, error} -> {:error, error}
      {:ok, nil} -> {:error, :not_found}
      {:ok, binary} -> {:ok, decode(binary)}
    end
  end

  def set(source, data) do
    case Redix.command(@conn, ["SET", "#{source}:#{data.id}", encode(data)]) do
      {:error, error} -> {:error, error}
      _ -> :ok
    end
  end

  def delete(source, id) do
    case Redix.command(@conn, ["DEL", "#{source}:#{id}"]) do
      {:error, error} -> {:error, error}
      _ -> :ok
    end
  end

  def delete_all() do
    case Redix.command(@conn, ["FLUSHDB"]) do
      {:error, error} -> {:error, error}
      _ -> :ok
    end
  end

  defp encode(data), do: data |> :erlang.term_to_binary() |> Base.encode16()

  defp decode(data) do
    with {_, result} <- Base.decode16(data) do
      :erlang.binary_to_term(result)
    end
  end
end
