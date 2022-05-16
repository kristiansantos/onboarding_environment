defmodule ProductsManager.Models.ExportJobTest do
  use ProductsManager.DataCase
  use ProductsManager.TirexsHttpMock
  use ProductsManager.RedixMock
  use ProductsManager.TaskBunnyMock

  alias ProductsManager.Jobs.ExportJob
  alias ProductsManager.Services.ExportService

  setup :verify_on_exit!

  describe "perfom/1" do
    test "Return success" do
      tirexs_mock_get(:ok, [])
      redix_mock_command(:ok, "SET", "tmp/path-file")

      filters = %{
        "filters" => %{"name" => "test_search", "price" => 50}
      }

      assert :ok == ExportJob.perform(filters)
    end

    test "Return error " do
      tirexs_mock_get(:ok, [])
      redix_mock_command(:error, "SET", nil)

      filters = %{
        "filters" => %{"name" => "test_search", "price" => 50}
      }

      assert :error == ExportJob.perform(filters)
    end
  end
end
