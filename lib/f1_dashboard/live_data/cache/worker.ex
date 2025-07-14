defmodule F1Dashboard.LiveData.Cache.Worker do
  require Logger

  use GenServer

  alias F1Dashboard.LiveData.Cache.{Scheduler, Storage, WorkerState}

  alias F1Dashboard.LiveData.Provider

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, nil, {:continue, :load_state}}
  end

  @impl true
  def handle_continue(:load_state, _state) do
    Logger.info("Loading intial data in the worker")

    new_state = load_state()
    Scheduler.schedule_session_check(self(), new_state)
    Scheduler.schedule_race_check(self(), new_state)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:check_session, state) do
    new_state = update_session(state)
    Scheduler.schedule_session_check(self(), new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(:check_events, %{session_ready: false} = state) do
    Scheduler.schedule_race_check(self(), state)
    {:noreply, state}
  end

  @impl true
  def handle_info(:check_events, state) do
    new_state = update_events(state)
    Scheduler.schedule_race_check(self(), new_state)
    {:noreply, new_state}
  end

  defp load_state() do
    with {:ok, session_data} <- Provider.session_data(),
         {:ok, _} <- Storage.store_session(session_data.session),
         {:ok, _} <- store_events() do
      Logger.info("Loaded initial state")
      WorkerState.default()
    else
      {:error, reason} ->
        Logger.error("Got an error while loading state #{inspect(reason)}")
        WorkerState.init()
    end
  end

  defp update_session(state) do
    with {:ok, session_data} <- Provider.session_data(),
         {:ok, status} <- Storage.store_session(session_data.session) do
      WorkerState.update_session_change(state, status)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating session #{inspect(reason)}, resetting state")
        WorkerState.init()
    end
  end

  defp update_events(state) do
    with {:ok, status} <- store_events() do
      WorkerState.update_events_change(state, status)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating events #{inspect(reason)}")
        state
    end
  end

  defp store_events() do
    Logger.info("Loading race events data")

    Storage.store_events(fn session ->
      case Provider.session_events(session) do
        {:ok, status} -> {:ok, status}
        error -> error
      end
    end)
  end
end
