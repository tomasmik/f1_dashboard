defmodule F1Dashboard.LiveData.RaceControl do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          category: String.t(),
          flag: String.t(),
          message: String.t(),
          scope: String.t(),
          sector: integer(),
          lap_number: integer(),
          date: NaiveDateTime.t(),
          driver_number: integer()
        }

  @primary_key false
  embedded_schema do
    field(:category, :string)
    field(:flag, :string)
    field(:message, :string)
    field(:scope, :string)
    field(:sector, :integer)
    field(:lap_number, :integer)
    field(:date, :naive_datetime)

    field(:driver_number, :integer)
  end

  def changeset(module \\ %__MODULE__{}, data)

  def changeset(module, data) when is_map(data) and not is_struct(data, __MODULE__) do
    module
    |> cast(data, [
      :category,
      :flag,
      :message,
      :scope,
      :sector,
      :lap_number,
      :date,
      :driver_number
    ])
    |> validate_required([:category, :date])
  end

  def changeset(_, %__MODULE__{} = data) do
    change(data)
    |> validate_required([:position, :driver_number])
  end
end
