defmodule ProductsManager.Services.Behaviours.TaskBunnyBehaviour do
  @type method_result :: :ok | {:ok, any}
  @type handle_error :: :error | {:error, any}

  @callback enqueue(atom, any):: method_result | handle_error
  @callback perform(any) :: method_result | handle_error
end
