defmodule F1Dashboard.LiveData.Weather do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          air_temperature: Decimal.t() | nil,
          track_temperature: Decimal.t() | nil,
          humidity: integer() | nil,
          rainfall: integer() | nil,
          wind_speed: Decimal.t() | nil,
          wind_direction: integer() | nil
        }

  @primary_key false
  embedded_schema do
    field(:air_temperature, :float)
    field(:track_temperature, :float)
    field(:humidity, :float)
    field(:rainfall, :integer)
    field(:wind_speed, :float)
    field(:wind_direction, :integer)
  end

  @doc false
  def changeset(%__MODULE__{} = struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [
      :air_temperature,
      :track_temperature,
      :humidity,
      :rainfall,
      :wind_speed,
      :wind_direction
    ])
    |> validate_required([:rainfall])
  end
end
