defmodule F1Dashboard.LiveData.Cache.Updater do
  require Logger

  alias F1Dashboard.LiveData.Provider
  alias F1Dashboard.LiveData.Cache.{Storage}

  def events() do
    Logger.info("Loading race events data")

    with {:ok, session} <- Storage.get_session(),
         {:ok, events} <- Provider.session_events(session) do
      Storage.store_events(events)
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
    with {:ok, session} <- Provider.session_latest(),
         {:ok, drivers} <- Provider.drivers_in_session(session) do
      update_session_cache(drivers, session)
      {:ok, session}
    end
  end

  defp refresh_session(current_session) do
    with {:ok, session} <- Provider.session_latest(),
         true <- session.session_key != current_session.session_key,
         {:ok, drivers} <- Provider.drivers_in_session(session) do
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
