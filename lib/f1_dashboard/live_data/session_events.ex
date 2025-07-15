defmodule F1Dashboard.LiveData.SessionEvents do
  @moduledoc """
  Represents an F1 all events in a single session.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias F1Dashboard.LiveData.{DriverEvent, RaceControl, Weather}

  @type t :: %__MODULE__{
          driver_events: [DriverEvent.t(), ...],
          race_control: [RaceControl.t(), ...] | nil,
          weather: Weather.t() | nil
        }

  @primary_key false
  embedded_schema do
    embeds_many(:driver_events, DriverEvent)
    embeds_many(:race_control, RaceControl)
    embeds_one(:weather, Weather)
  end

  def changeset(data) do
    %__MODULE__{}
    |> cast(data, [])
    |> cast_embed(:driver_events, required: true, with: &DriverEvent.changeset/2)
    |> cast_embed(:race_control, required: false, with: &RaceControl.changeset/2)
    |> cast_embed(:weather, required: false, with: &Weather.changeset/2)
  end
end
