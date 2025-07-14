defmodule F1Dashboard.LiveData.Provider do
  import F1Dashboard.Helpers.Data

  alias F1Dashboard.LiveData.SessionData
  alias F1Dashboard.LiveData
  alias F1Dashboard.LiveData.Provider

  alias LiveData.{Session, SessionData, SessionEvents}

  @type data_result(t) :: {:ok, t} | {:error, any()}

  @spec session_data() :: data_result(SessionData.t())
  def session_data() do
    case Provider.Session.latest() do
      {:ok, data} ->
        normalize(data, SessionData)

      {:error, error} ->
        {:error, error}
    end
  end

  @spec session_events(Session.t()) :: data_result(SessionEvents.t())
  def session_events(%Session{} = session) do
    case Provider.Events.for_session(session) do
      {:ok, data} ->
        normalize(data, SessionEvents)

      {:error, error} ->
        {:error, error}
    end
  end
end
