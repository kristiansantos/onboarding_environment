defmodule ProductsManager.RedisConnetion do
  def child_spec(_args) do
    Redix.child_spec({Application.get_env(:redix, :host), name: :redis_connection})
  end
end
