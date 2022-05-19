defmodule ProductsManagerWeb.ExportController do
  use ProductsManagerWeb, :controller

  alias ProductsManager.Jobs.ExportJob
  alias ProductsManager.Services.RedisService

  action_fallback ProductsManagerWeb.FallbackController

  plug :optional_params when action in [:create]

  @task_bunny Application.get_env(:task_bunny, :lib)

  def index(conn, _) do
    with {:ok, tmp_file} <- RedisService.get_by("export", "job") do
      send_download(conn, {:file, tmp_file[:path]})
    end
  end

  def create(conn, params) do
    case @task_bunny.enqueue(ExportJob, params) do
      :ok -> send_resp(conn, 202, "Export is being processed with success")
      _error -> send_resp(conn, 500, "Error in export request")
    end
  end

  defp optional_params(conn, _) do
    %{conn | params: Map.merge(%{"filters" => %{}}, conn.params)}
  end
end
