defmodule F1Dashboard.LiveData.Position do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          position: integer(),
          driver_number: integer()
        }

  @primary_key false
  embedded_schema do
    field(:position, :integer)
    field(:driver_number, :integer)
  end

  def changeset(module \\ %__MODULE__{}, data)

  def changeset(module, data) when is_map(data) and not is_struct(data, __MODULE__) do
    module
    |> cast(data, [:position, :driver_number])
    |> validate_required([:driver_number])
  end

  def changeset(_, %__MODULE__{} = data) do
    change(data)
    |> validate_required([:position, :driver_number])
  end
end
