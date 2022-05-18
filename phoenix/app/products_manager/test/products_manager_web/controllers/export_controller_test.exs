defmodule ProductsManagerWeb.ExportControllerTest do
  use ProductsManagerWeb.ConnCase
  use ProductsManager.TirexsHttpMock
  use ProductsManager.RedixMock
  use ProductsManager.TaskBunnyMock

  alias ProductsManager.Services.ExportService

  setup :verify_on_exit!

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index/2" do
    setup [:export_fixture]

    test "Return file to download", %{conn: conn, path: tmp_file_path} do
      redix_mock_command(:ok, "GET", %{id: "job", path: tmp_file_path})

      conn = get(conn, Routes.export_path(conn, :index))

      assert response(conn, 200)
    end

    test "Render error with not found export", %{conn: conn} do
      redix_mock_command(:ok, "GET", nil)

      conn =
        conn
        |> get(Routes.export_path(conn, :index))
        |> json_response(404)

      assert conn["errors"] == %{"detail" => "Not Found"}
    end
  end

  describe "create/2" do
    test "Renders success with empty filters", %{conn: conn} do
      task_bunny_mock_enqueue(:ok, [])

      conn = post(conn, Routes.export_path(conn, :create))

      assert "Export is being processed with success" == conn.resp_body
    end

    test "Renders error with empty filters", %{conn: conn} do
      task_bunny_mock_enqueue(:error, [])

      conn = post(conn, Routes.export_path(conn, :create))

      assert "Error in export request" == conn.resp_body
    end

    test "Renders success with filters", %{conn: conn} do
      task_bunny_mock_enqueue(:ok, [])

      conn =
        post(conn, Routes.export_path(conn, :create), %{
          "filters" => %{"name" => "test_search", "price" => 50}
        })

      assert "Export is being processed with success" == conn.resp_body
    end

    test "Renders error with filters", %{conn: conn} do
      task_bunny_mock_enqueue(:error, [])

      conn =
        post(conn, Routes.export_path(conn, :create), %{
          "filters" => %{"name" => "test_search", "price" => 50}
        })

      assert "Error in export request" == conn.resp_body
    end
  end

  defp export_fixture(_) do
    redix_mock_command(:ok, "SET", "export:job")

    {:ok, tmp_file_path} =
      Enum.map(1..10, fn number -> %{id: number, name: "test-#{number}"} end)
      |> ExportService.to_csv()

    %{path: tmp_file_path}
  end
end
