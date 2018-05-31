defmodule Squirrel.Analyses.Analysis do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analyses" do
    field(:subject, :string)
    field(:predicate, :integer)
    field(:object, :map)

    timestamps()
  end

  @doc false
  def changeset(analysis, attrs) do
    analysis
    |> cast(attrs, [:subject, :predicate, :object])
    |> validate_required([:subject, :predicate])
  end
end
