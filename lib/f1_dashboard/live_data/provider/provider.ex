defmodule F1Dashboard.LiveData.Provider do
  import F1Dashboard.Helpers.Data

  alias F1Dashboard.LiveData
  alias F1Dashboard.LiveData.Provider

  alias Provider.Caller
  alias Provider.Transformer

  alias LiveData.{Session, Driver, SessionEvents}

  @type data_result(t) :: {:ok, t} | {:error, any()}

  @spec session_latest() :: data_result(Session.t())
  def session_latest() do
    with {:ok, sessions} <- Caller.session_latest(),
         {:ok, one} <- Transformer.get_one(sessions),
         {:ok, normalized} <- normalize(one, Session) do
      {:ok, normalized}
    end
  end

  @spec session_events(Session.t()) :: data_result(SessionEvents.t())
  def session_events(%Session{} = session) do
    case Provider.SessionEvents.get_and_build_all(session) do
      {:ok, data} ->
        normalize(data, SessionEvents)

      {:error, error} ->
        {:error, error}
    end
  end

  @spec drivers_in_session(Session.t()) :: data_result([Driver.t(), ...])
  def drivers_in_session(%Session{} = session) do
    with {:ok, drivers} <- Caller.drivers(session),
         {:ok, normalized} <- normalize(drivers, Driver) do
      {:ok, normalized}
    end
  end
end
