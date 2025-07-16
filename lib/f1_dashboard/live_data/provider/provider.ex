defmodule F1Dashboard.LiveData.Provider do
  import F1Dashboard.Helpers.Data

  alias F1Dashboard.LiveData.SessionData
  alias F1Dashboard.LiveData
  alias F1Dashboard.LiveData.Provider

  alias LiveData.{Session, SessionData, SessionEvents}

  @type data_result(t) :: {:ok, t} | {:error, any()}

  @spec session_data() :: data_result(SessionData.t())
  def session_data() do
    with {:ok, session} <- Provider.Session.latest(),
         {:ok, struct} <- normalize(session, SessionData) do
      {:ok, struct}
    end
  end

  @spec session_events(Session.t()) :: data_result(SessionEvents.t())
  def session_events(%Session{} = session) do
    with {:ok, events} <- Provider.Events.for_session(session),
         {:ok, struct} <- normalize(events, SessionEvents) do
      {:ok, struct}
    end
  end
end
