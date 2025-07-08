defmodule F1Dashboard.LiveData do
  import F1Dashboard.Helpers.Data

  alias F1Dashboard.LiveData.BuilderSessionEvents
  alias F1Dashboard.LiveData.BuilderDriverEvents
  alias F1Dashboard.LiveData.Caller
  alias F1Dashboard.LiveData.Transformer

  alias F1Dashboard.LiveData.{Session, Driver, SessionEvents, DriverEvents}

  @type data_result(t) :: {:ok, t} | {:error, any()}

  @spec get_session_latest() :: data_result(Session.t())
  def get_session_latest() do
    with {:ok, sessions} <- Caller.session_latest(),
         {:ok, one} <- Transformer.get_one(sessions),
         {:ok, normalized} <- normalize(one, Session) do
      {:ok, normalized}
    end
  end

  @spec get_session_events(Session.t()) :: data_result(SessionEvents.t())
  def get_session_events(%Session{} = session) do
    case BuilderSessionEvents.get_and_build_all(session) do
      {:ok, data} ->
        normalize(data, SessionEvents)

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_driver_events([Driver.t(), ...], SessionEvents.t()) ::
          data_result([DriverEvents.t(), ...])
  def get_driver_events(drivers, %SessionEvents{} = events) when is_list(drivers) do
    BuilderDriverEvents.build(drivers, events)
    |> normalize(DriverEvents)
  end

  @spec get_drivers_in_session(Session.t()) :: data_result([Driver.t(), ...])
  def get_drivers_in_session(%Session{} = session) do
    with {:ok, drivers} <- Caller.drivers(session),
         {:ok, normalized} <- normalize(drivers, Driver) do
      {:ok, normalized}
    end
  end
end
