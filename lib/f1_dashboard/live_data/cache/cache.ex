defmodule F1Dashboard.LiveData.Cache do
  require Logger

  use GenServer

  alias F1Dashboard.LiveData.{SessionData, SessionEvents}

  @storage Application.compile_env(
             :f1_dashboard,
             :cache_storage,
             F1Dashboard.LiveData.Cache.ETS
           )

  @type cache_result(t) :: {:ok, t} | {:error, :not_found}
  @type events :: SessionEvents.t()
  @type session_data :: SessionData.t()
  @type session_callback :: (SessionData.t() -> {:ok, SessionEvents.t()} | {:error, any()})

  def get_session_data(), do: @storage.get_session_data()
  def get_events(), do: @storage.get_events()

  @spec store_events(session_callback()) :: {:ok, atom()} | {:error, any()}
  def store_events(fun) do
    GenServer.call(__MODULE__, {:put_events, fun})
  end

  @spec store_session_data(session_data()) :: {:ok, atom()} | {:error, any()}
  def store_session_data(data) do
    GenServer.call(__MODULE__, {:put_session_data, data})
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
    {:ok, %{table: @storage.init()}}
  end

  @impl true
  def handle_call({:put_session_data, data}, _from, state) do
    {:reply, @storage.store_session_data(data), state}
  end

  @impl true
  def handle_call({:put_events, fun}, _from, state) do
    {:reply, @storage.store_all_events(fun), state}
  end

  @impl true
  def handle_call(:clear_table, _from, state) do
    @storage.clear()
    {:reply, :ok, state}
  end
end
