defmodule F1Dashboard.LiveData.Cache.Updater do
  require Logger

  alias F1Dashboard.LiveData.Session
  alias F1Dashboard.LiveData.Cache.{WorkerState, Storage}
  alias F1Dashboard.LiveData.Provider

  def load_initial_state do
    with {:ok, session_data} <- Provider.session_data(),
         {:ok, _} <- Storage.store_session_data(session_data),
         {:ok, _} <- store_events() do
      Logger.info("Loaded initial state")
      WorkerState.default()
    else
      {:error, reason} ->
        Logger.error("Got an error while loading state #{inspect(reason)}")
        WorkerState.init()
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
      WorkerState.update_events_change(state, status)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating events #{inspect(reason)}")
        state
    end
  end

  defp load_session(state) do
    with {:ok, session_data} <- Provider.session_data(),
         {:ok, status} <- Storage.store_session_data(session_data) do
      WorkerState.update_session_change(state, status)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating session #{inspect(reason)}, resetting state")
        WorkerState.init()
    end
  end

  defp store_events() do
    Logger.info("Loading race events data")

    Storage.store_events(fn session_data ->
      case Provider.session_events(session_data.session) do
        {:ok, status} -> {:ok, status}
        error -> error
      end
    end)
  end

  defp refresh_session?() do
    case Storage.get_session_data() do
      {:ok, session_data} ->
        Session.status(session_data.session) in [:completed]

      _ ->
        true
    end
  end
end
