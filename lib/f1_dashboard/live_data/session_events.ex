defmodule F1Dashboard.LiveData.SessionEvents do
  @moduledoc """
  Represents an F1 all events in a single session.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias F1Dashboard.LiveData.{Interval, Pit, Position, Stint, RaceControl}

  @type t :: %__MODULE__{
          interval: [Interval.t()],
          pit: [Pit.t()],
          position: [Position.t()],
          race_control: [RaceControl.t()],
          stints: [Stint.t()]
        }

  @primary_key false
  embedded_schema do
    embeds_many(:interval, Interval)
    embeds_many(:pit, Pit)
    embeds_many(:position, Position)
    embeds_many(:stints, Stint)
    embeds_many(:race_control, RaceControl)
  end

  def changeset(data) do
    %__MODULE__{}
    |> cast(data, [])
    |> cast_embed(:interval, required: true, with: &Interval.changeset/2)
    |> cast_embed(:pit, required: true, with: &Pit.changeset/2)
    |> cast_embed(:position, required: true, with: &Position.changeset/2)
    |> cast_embed(:stints, required: true, with: &Stint.changeset/2)
    |> cast_embed(:race_control, required: true, with: &RaceControl.changeset/2)
  end
end
