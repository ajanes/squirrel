defmodule Squirrel.Helpers.PeriodicTask do
  use GenServer

  def start_link(args) do
    GenServer.start_link(
      __MODULE__,
      args,
      name: :periodic_task
    )
  end

  @impl true
  def init(args) do
    %{seconds: seconds} = args
    Process.send_after(self(), :work, seconds * 1000)
    {:ok, args}
  end

  @impl true
  def handle_info(:work, state) do
    %{seconds: seconds, function: function} = state

    function.()
    Process.send_after(self(), :work, seconds * 1000)

    {:noreply, state}
  end

  def child_spec(%{seconds: seconds, function: function}) do
    %{
      id: :periodic_task,
      start:
        {Squirrel.Helpers.PeriodicTask, :start_link, [%{seconds: seconds, function: function}]}
    }
  end
end
