defmodule ProductsManager.ExportServiceTest do
  use ProductsManager.DataCase
  use ProductsManager.RedixMock

  alias ProductsManager.Services.ExportService

  setup :verify_on_exit!

  describe "to_csv/1" do
    test "With valid data" do
      redix_mock_command(:ok, "SET", "tmp/path-file")

      data = Enum.map(1..10, fn number -> %{id: number, name: "test-#{number}"} end)

      assert {:ok, _} = ExportService.to_csv(data)
    end

    test "With invalid data" do
      assert_raise BadMapError, fn -> ExportService.to_csv([0, 1, 2, 3, 4]) end
    end
  end
end
