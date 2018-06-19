defmodule Squirrel.Repo.Migrations.AddFacts do
  use Ecto.Migration

  def change do
    create table(:facts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:subject, :string, size: 1000)
      add(:predicate, :integer)
      add(:object, :map)
      add(:source, :binary_id)
      add(:topic, :binary_id, null: false)
      add(:received_at, :naive_datetime)
      add(:expires_at, :naive_datetime)

      timestamps()
    end

    create(index(:facts, [:topic, :subject, :predicate]))
  end
end
