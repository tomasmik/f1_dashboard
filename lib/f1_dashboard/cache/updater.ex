defmodule F1Dashboard.Cache.Updater do
  require Logger

  alias F1Dashboard.LiveData
  alias F1Dashboard.Cache.{Storage}

  def events() do
    Logger.info("Loading race events data")

    with {:ok, session} <- Storage.get_session(),
         {:ok, drivers} <- Storage.get_drivers(),
         {:ok, events} <- LiveData.get_session_events(session),
         {:ok, driver_events} <- LiveData.get_driver_events(drivers, events) do
      Storage.store_events(events)
      Storage.store_driver_events(driver_events)
      {:ok, events}
    end
  end

  def session() do
    Logger.info("Loading session data")

    case Storage.get_session() do
      {:error, :not_found} ->
        load_session()

      {:ok, session} ->
        refresh_session(session)
    end
  end

  defp load_session() do
    with {:ok, session} <- LiveData.get_session_latest(),
         {:ok, drivers} <- LiveData.get_drivers_in_session(session) do
      update_session_cache(drivers, session)
      {:ok, session}
    end
  end

  defp refresh_session(current_session) do
    with {:ok, session} <- LiveData.get_session_latest(),
         true <- session.session_key != current_session.session_key,
         {:ok, drivers} <- LiveData.get_drivers_in_session(session) do
      update_session_cache(drivers, session)
      {:ok, session}
    else
      false ->
        Logger.info("Session unchanged. keeping current state")
        {:ok, current_session}

      err ->
        err
    end
  end

  defp update_session_cache(drivers, session) do
    Storage.clear_table()

    Storage.store_drivers(drivers)
    Storage.store_session(session)
  end
end
