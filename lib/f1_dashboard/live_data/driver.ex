defmodule F1Dashboard.LiveData.Driver do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          broadcast_name: String.t(),
          headshot_url: String.t(),
          name_acronym: String.t(),
          team_colour: String.t(),
          team_name: String.t(),
          driver_number: integer()
        }

  @primary_key false
  embedded_schema do
    field(:broadcast_name, :string)
    field(:headshot_url, :string)
    field(:name_acronym, :string)
    field(:team_colour, :string)
    field(:team_name, :string)
    field(:driver_number, :integer)
  end

  def changeset(%__MODULE__{} = driver, data \\ %{}) do
    driver
    |> cast(data, [
      :broadcast_name,
      :headshot_url,
      :name_acronym,
      :team_colour,
      :team_name,
      :driver_number
    ])
    |> validate_required([
      :broadcast_name,
      :name_acronym,
      :team_colour,
      :team_name,
      :driver_number
    ])
  end
end
