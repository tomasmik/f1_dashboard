defmodule F1Dashboard.Cache.Storage do
  require Logger

  use GenServer

  alias F1Dashboard.LiveData.{Session, SessionEvents, Driver, DriverEvents}

  alias F1Dashboard.Cache.ETS

  @type cache_result(t) :: {:ok, t} | {:error, :not_found}
  @type drivers :: [Driver.t(), ...]
  @type driver :: Driver.t()
  @type driver_events :: [DriverEvents.t(), ...]
  @type events :: SessionEvents.t()
  @type session :: Session.t()

  def result_ok({:error, :not_found}), do: {:ok, nil}
  def result_ok({:ok, value}), do: {:ok, value}

  defdelegate get_driver_events, to: ETS
  defdelegate get_session, to: ETS
  defdelegate get_events, to: ETS
  defdelegate get_driver(driver_id), to: ETS
  defdelegate get_drivers(), to: ETS

  @spec store_session(session()) :: :ok
  def store_session(%Session{} = session) do
    GenServer.call(__MODULE__, {:put_session, session})
  end

  @spec store_events(events()) :: :ok
  def store_events(%SessionEvents{} = events) do
    GenServer.call(__MODULE__, {:put_events, events})
  end

  @spec store_drivers(drivers()) :: :ok
  def store_drivers(drivers) when is_list(drivers) do
    GenServer.call(__MODULE__, {:put_drivers, drivers})
  end

  @spec store_driver_events(driver_events()) :: :ok
  def store_driver_events(events) when is_list(events) do
    GenServer.call(__MODULE__, {:put_driver_events, events})
  end

  def clear_table() do
    GenServer.call(__MODULE__, :clear_table)
  end

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, %{table: ETS.init()}}
  end

  @impl true
  def handle_call({:put_session, session}, _from, state) do
    ETS.store_session(session)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:put_events, events}, _from, state) do
    ETS.store_all_events(events)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:put_driver_events, events}, _from, state) do
    ETS.store_driver_events(events)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:put_drivers, drivers}, _from, state) do
    ETS.store_drivers(drivers)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:clear_table, _from, state) do
    ETS.clear_table()
    {:reply, :ok, state}
  end
end
