defmodule ProductsManager.Services.ExportService do
  alias ProductsManager.Services.RedisService

  def to_csv(data) do
    tmp_file_path = path()
    tmp_file = File.open!(tmp_file_path, [:write, :utf8])

    data
    |> CSV.encode(headers: true)
    |> Enum.each(&IO.write(tmp_file, &1))

    File.close(tmp_file)

    case cache_export(tmp_file_path) do
      :ok -> {:ok, tmp_file_path}
      {:error, error} -> {:error, error}
    end
  end

  defp path(),
    do: System.tmp_dir!() |> Path.join("export-#{DateTime.to_iso8601(DateTime.utc_now())}.csv")

  defp cache_export(file_path), do: RedisService.set("export", %{id: "job", path: file_path})
end
