defmodule ProductsManager.Models.ExportJobTest do
  use ProductsManager.DataCase
  use ProductsManager.TirexsHttpMock
  use ProductsManager.RedixMock

  alias ProductsManager.Jobs.ExportJob

  setup :verify_on_exit!

  setup_all do
    %{
      "filters" => %{"name" => "test_search", "price" => 50}
    }
  end

  describe "perfom/1" do
    test "Return success", filter_params do
      tirexs_mock_get(:ok, [])
      redix_mock_command(:ok, "SET", "tmp/path-file")

      assert {:ok, _} = ExportJob.perform(filter_params)
    end

    test "Returns error when Redis fails", filter_params do
      tirexs_mock_get(:ok, [])
      redix_mock_command(:error, "SET", nil)

      assert :error == ExportJob.perform(filter_params)
    end
  end
end
