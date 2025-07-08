defmodule F1Dashboard.LiveData.Stint do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          compound: String.t(),
          lap_start: integer(),
          lap_end: integer(),
          stint_number: integer(),
          tire_age_at_start: integer(),
          driver_number: integer()
        }

  @primary_key false
  embedded_schema do
    field(:compound, :string)
    field(:lap_start, :integer)
    field(:lap_end, :integer)
    field(:stint_number, :integer)
    field(:tire_age_at_start, :integer)
    field(:driver_number, :integer)
  end

  def changeset(module \\ %__MODULE__{}, data)

  def changeset(module, data) when is_map(data) and not is_struct(data, __MODULE__) do
    module
    |> cast(data, [
      :compound,
      :lap_start,
      :lap_end,
      :stint_number,
      :tire_age_at_start,
      :driver_number
    ])
    |> validate_required([
      :compound,
      :lap_start,
      :lap_end,
      :stint_number,
      :driver_number
    ])
  end

  def changeset(_, %__MODULE__{} = data) do
    change(data)
    |> validate_required([
      :compound,
      :lap_start,
      :lap_end,
      :stint_number,
      :driver_number
    ])
  end
end
