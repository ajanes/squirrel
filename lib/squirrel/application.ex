defmodule Squirrel.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      Squirrel.Repo,
      # Start the endpoint when the application starts
      SquirrelWeb.Endpoint,
      Squirrel.Data.Stash,
      Squirrel.Data,
      {Squirrel.Helpers.PeriodicTask,
       %{seconds: 60 * 10, function: fn -> Squirrel.Data.persist() end}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Squirrel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SquirrelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
