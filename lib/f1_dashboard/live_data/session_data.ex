defmodule F1Dashboard.LiveData.SessionData do
  alias F1Dashboard.LiveData

  alias LiveData.Driver
  alias LiveData.Session

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          session: Session.t(),
          drivers: [Driver.t(), ...]
        }

  @primary_key false
  embedded_schema do
    embeds_one(:session, Session)
    embeds_many(:drivers, Driver)
  end

  def changeset(data) do
    %__MODULE__{}
    |> cast(data, [])
    |> cast_embed(:session, with: &Session.changeset/2)
    |> cast_embed(:drivers, with: &Driver.changeset/2)
  end

  def drivers_by_number(%__MODULE__{drivers: drivers}) do
    Map.new(drivers, fn driver -> {driver.driver_number, driver} end)
  end
end
