defmodule ProductsManager.Models.ExportJobTest do
  use ProductsManager.DataCase
  use ProductsManager.TirexsHttpMock
  use ProductsManager.RedixMock
  use ProductsManager.TaskBunnyMock

  alias ProductsManager.Jobs.ExportJob
  alias ProductsManager.Services.ExportService

  setup :verify_on_exit!

  describe "perfom/1" do
    setup [:export_fixture]

    test "When all params are valid, returns success", %{path: tmp_file_path} do
      tirexs_mock_get(:ok, [])
      redix_mock_command(:ok, "GET", %{id: "job", path: tmp_file_path})

      filters = %{
        "filters" => %{"name" => "test_search", "price" => 50}
      }

      assert :ok == ExportJob.perform(filters)
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
