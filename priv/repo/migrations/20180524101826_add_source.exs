defmodule Squirrel.Repo.Migrations.AddSource do
  use Ecto.Migration

  def change do
    alter table(:facts) do
      add :source, :binary_id
    end
  end
end
