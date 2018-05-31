defmodule Squirrel.Repo.Migrations.AddFacts do
  use Ecto.Migration

  def change do
    create table(:facts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subject, :string, size: 1000
      add :predicate, :integer
      add :object, :map

      timestamps()
    end

    create index(:facts, [:subject, :predicate])
  end
end
