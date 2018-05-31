defmodule Squirrel.Data.Fact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "facts" do
    field(:subject, :string)
    field(:predicate, :integer)
    field(:object, :map)
    field(:source, :binary_id)

    timestamps()
  end

  @doc false
  def changeset(fact, attrs) do
    fact
    |> cast(attrs, [:subject, :predicate, :object, :source])
    |> validate_required([:subject, :predicate, :source])
  end
end
