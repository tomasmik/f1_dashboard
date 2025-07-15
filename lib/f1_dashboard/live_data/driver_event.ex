defmodule F1Dashboard.LiveData.DriverEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias F1Dashboard.LiveData.{Interval, Pit, Position, Stint}

  @type t :: %__MODULE__{
          driver_number: integer(),
          interval: Interval.t(),
          pit: Pit.t(),
          position: Position.t(),
          stint: Stint.t()
        }

  @primary_key false
  embedded_schema do
    field(:driver_number, :integer)

    embeds_one(:interval, Interval)
    embeds_one(:pit, Pit)
    embeds_one(:position, Position)
    embeds_one(:stint, Stint)
  end

  def changeset(%__MODULE__{} = module, data \\ %{}) do
    module
    |> cast(data, [:driver_number])
    |> cast_embed(:position, required: true, with: &Position.changeset/2)
    |> cast_embed(:interval, required: false, with: &Interval.changeset/2)
    |> cast_embed(:pit, required: false, with: &Pit.changeset/2)
    |> cast_embed(:stint, required: false, with: &Stint.changeset/2)
    |> validate_required([:driver_number])
  end
end
