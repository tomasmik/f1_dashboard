defmodule F1Dashboard.LiveData.Interval do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          gap_to_leader: String.t(),
          interval: String.t(),
          driver_number: integer()
        }

  @primary_key false
  embedded_schema do
    # The time gap to the race leader in seconds,
    # +1 LAP if lapped, or null for the race leader.
    field(:gap_to_leader, :string)
    field(:interval, :string)

    field(:driver_number, :integer)
  end

  def changeset(module \\ %__MODULE__{}, data)

  def changeset(module, data) when is_map(data) and not is_struct(data, __MODULE__) do
    normalized_data = normalize_string_fields(data)

    module
    |> cast(normalized_data, [:gap_to_leader, :interval, :driver_number])
    |> validate_required([:driver_number])
  end

  def changeset(_, %__MODULE__{} = data) do
    change(data)
    |> validate_required([:driver_number])
  end

  defp normalize_string_fields(data) do
    data
    |> Map.update("gap_to_leader", nil, &safe_to_string/1)
    |> Map.update("interval", nil, &safe_to_string/1)
  end

  defp safe_to_string(nil), do: nil
  defp safe_to_string(value) when is_binary(value), do: value
  defp safe_to_string(value), do: to_string(value)
end
