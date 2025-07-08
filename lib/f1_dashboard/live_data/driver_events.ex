defmodule F1Dashboard.LiveData.DriverEvents do
  @moduledoc """
  Represents events in a single F1 session for a single driver.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias F1Dashboard.LiveData.{Interval, Pit, Position, Stint}

  @type t :: %__MODULE__{
          driver_number: integer(),
          position: Position.t(),
          interval: Interval.t() | nil,
          pit: Pit.t() | nil,
          stint: Stint.t() | nil
        }

  @primary_key false
  embedded_schema do
    field(:driver_number, :integer)
    embeds_one(:interval, Interval)
    embeds_one(:pit, Pit)
    embeds_one(:position, Position)
    embeds_one(:stint, Stint)
  end

  def changeset(data) do
    %__MODULE__{}
    |> cast(data, [:driver_number])
    |> validate_required([:driver_number])
    |> cast_embed(:position, required: true, with: &Position.changeset/2)
    |> cast_embed(:interval, required: false, with: &Interval.changeset/2)
    |> cast_embed(:pit, required: false, with: &Pit.changeset/2)
    |> cast_embed(:stint, required: false, with: &Stint.changeset/2)
  end
end
