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
    field(:topic, :binary_id)
    field(:received_at, :naive_datetime)
    field(:expires_at, :naive_datetime)
    field(:is_persisted, :boolean, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(fact, attrs) do
    fact
    |> cast(attrs, [
      :expires_at,
      :is_persisted,
      :object,
      :predicate,
      :received_at,
      :source,
      :subject,
      :topic
    ])
    |> validate_required([:subject, :predicate, :source, :topic])
  end
end
