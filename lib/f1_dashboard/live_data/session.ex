defmodule F1Dashboard.LiveData.Session do
  @moduledoc """
  Represents an F1 session's live data.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          circuit_short_name: String.t(),
          country_name: String.t(),
          date_end: NaiveDateTime.t(),
          date_start: NaiveDateTime.t(),
          session_type: String.t(),
          session_key: integer(),
          meeting_key: integer()
        }

  @primary_key false
  embedded_schema do
    field(:circuit_short_name, :string)
    field(:country_name, :string)
    field(:date_end, :naive_datetime)
    field(:date_start, :naive_datetime)
    field(:session_type, :string)
    field(:session_key, :integer)
    field(:meeting_key, :integer)
  end

  def changeset(%__MODULE__{} = session, data \\ %{}) do
    session
    |> cast(data, [
      :circuit_short_name,
      :country_name,
      :date_end,
      :date_start,
      :session_type,
      :session_key,
      :meeting_key
    ])
    |> validate_required([
      :circuit_short_name,
      :country_name,
      :date_end,
      :date_start,
      :session_type,
      :session_key,
      :meeting_key
    ])
  end

  def status(%__MODULE__{} = session) do
    now = NaiveDateTime.utc_now()

    cond do
      NaiveDateTime.compare(now, session.date_start) == :lt -> :upcoming
      NaiveDateTime.compare(now, session.date_end) == :gt -> :completed
      true -> :live
    end
  end

  def status_display(%__MODULE__{} = session) do
    case status(session) do
      :upcoming -> "upcoming"
      :live -> "live"
      :completed -> "completed"
    end
  end
end
