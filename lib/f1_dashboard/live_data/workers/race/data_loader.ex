defmodule F1Dashboard.LiveData.Workers.Race.DataLoader do
  require Logger

  alias F1Dashboard.LiveData.Session
  alias F1Dashboard.LiveData.Provider
  alias F1Dashboard.LiveData.Cache
  alias F1Dashboard.LiveData.Workers.Race.State

  def load_initial_state do
    with {:ok, session_data} <- Provider.session_data(),
         {:ok, _} <- Cache.store_session_data(session_data),
         {:ok, _} <- store_events() do
      Logger.info("Loaded initial state")
      State.default()
    else
      {:error, reason} ->
        Logger.error("Got an error while loading state #{inspect(reason)}")
        State.init()
    end
  end

  def maybe_load_session(state) do
    case refresh_session?() do
      true ->
        load_session(state)

      false ->
        Logger.info("Skipping session check, will not load new session data")
        state
    end
  end

  def load_events(state) do
    with {:ok, status} <- store_events() do
      State.update_events_change(state, status)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating events #{inspect(reason)}")
        state
    end
  end

  defp load_session(state) do
    with {:ok, session_data} <- Provider.session_data(),
         {:ok, status} <- Cache.store_session_data(session_data) do
      State.update_session_change(state, status)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating session #{inspect(reason)}, resetting state")
        State.init()
    end
  end

  defp store_events() do
    Logger.info("Loading race events data")

    Cache.store_events(fn session_data ->
      case Provider.session_events(session_data.session) do
        {:ok, status} -> {:ok, status}
        error -> error
      end
    end)
  end

  defp refresh_session?() do
    case Cache.get_session_data() do
      {:ok, session_data} ->
        Session.status(session_data.session) in [:completed]

      _ ->
        true
    end
  end
end
