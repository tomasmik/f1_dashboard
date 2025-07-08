defmodule F1Dashboard.LiveData.Pit do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          pit_duration: float(),
          lap_number: integer(),
          date: NaiveDateTime.t(),
          driver_number: integer()
        }

  @primary_key false
  embedded_schema do
    field(:pit_duration, :float)
    field(:lap_number, :integer)
    field(:date, :naive_datetime)

    field(:driver_number, :integer)
  end

  def changeset(module \\ %__MODULE__{}, data)

  def changeset(module, data) when is_map(data) and not is_struct(data, __MODULE__) do
    module
    |> cast(data, [:pit_duration, :lap_number, :date, :driver_number])
    |> validate_required([:driver_number, :date])
  end

  def changeset(_, %__MODULE__{} = data) do
    change(data)
    |> validate_required([:driver_number, :date])
  end
end
