defmodule Squirrel.Data.Analysis do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "analyses" do
    field(:subject, :string)
    field(:predicate, :integer)
    field(:object, :map)
    field(:topic, :binary_id)
    field(:expires_at, :naive_datetime)
    field(:is_persisted, :boolean, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(analysis, attrs) do
    analysis
    |> cast(attrs, [:expires_at, :is_persisted, :object, :predicate, :subject, :topic])
    |> validate_required([:subject, :predicate])
  end
end
