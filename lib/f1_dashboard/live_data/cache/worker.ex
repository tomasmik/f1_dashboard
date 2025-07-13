defmodule F1Dashboard.LiveData.Cache.Worker do
  require Logger

  use GenServer

  alias F1Dashboard.LiveData.Cache.{Scheduler, Updater, Storage, WorkerState}

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
    with {:ok, _} <- Updater.session(),
         {:ok, _} <- Updater.events() do
      WorkerState.default()
    else
      {:error, reason} ->
        Logger.error("Got an error while loading initial state #{inspect(reason)}")
        WorkerState.init()
    end
  end

  defp update_session(state) do
    with {:ok, old} <- Storage.result_ok(Storage.get_session()),
         {:ok, new} <- Updater.session() do
      WorkerState.update_session_change(state, old, new)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating session #{inspect(reason)}, resetting state")
        WorkerState.init()
    end
  end

  defp update_events(state) do
    with {:ok, old} <- Storage.result_ok(Storage.get_events()),
         {:ok, new} <- Updater.events() do
      WorkerState.update_events_change(state, old, new)
    else
      {:error, reason} ->
        Logger.error("Got an error while updating events #{inspect(reason)}")
        state
    end
  end
end
