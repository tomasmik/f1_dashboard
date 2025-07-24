defmodule F1Dashboard.LiveData.Workers.Race do
  require Logger

  use GenServer

  alias F1Dashboard.LiveData.Workers.Race.{Scheduler, DataLoader}

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

    new_state = DataLoader.load_initial_state()
    Scheduler.schedule_session_check(self(), new_state)
    Scheduler.schedule_race_check(self(), new_state)

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:check_session, state) do
    new_state = DataLoader.maybe_load_session(state)
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
    new_state = DataLoader.load_events(state)
    Scheduler.schedule_race_check(self(), new_state)
    {:noreply, new_state}
  end
end
