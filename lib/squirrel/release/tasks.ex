defmodule Squirrel.Release.Tasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:squirrel)
    path = Application.app_dir(:squirrel, "priv/repo/migrations")
    Ecto.Migrator.run(Squirrel.Repo, path, :up, all: true)
  end
end
