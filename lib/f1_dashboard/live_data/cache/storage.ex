defmodule F1Dashboard.LiveData.Cache.Storage do
  require Logger

  use GenServer

  alias F1Dashboard.LiveData.{SessionData, SessionEvents}

  alias F1Dashboard.LiveData.Cache.ETS

  @type cache_result(t) :: {:ok, t} | {:error, :not_found}
  @type events :: SessionEvents.t()
  @type session_data :: SessionData.t()

  def result_ok({:error, :not_found}), do: {:ok, nil}
  def result_ok({:ok, value}), do: {:ok, value}

  def result_or_default({:error, any}, default) do
    Logger.warning("Failed to load data: #{inspect(any)}")
    default
  end

  def result_or_default(value, _), do: value

  defdelegate get_session, to: ETS
  defdelegate get_events, to: ETS

  @spec store_events(function()) :: {:ok, atom()} | {:error, any()}
  def store_events(fun) do
    GenServer.call(__MODULE__, {:put_events, fun})
  end

  @spec store_session(session_data()) :: {:ok, atom()} | {:error, any()}
  def store_session(data) do
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
    {:ok, %{table: ETS.init()}}
  end

  @impl true
  def handle_call({:put_session_data, data}, _from, state) do
    {:reply, ETS.store_session(data), state}
  end

  @impl true
  def handle_call({:put_events, fun}, _from, state) do
    {:reply, ETS.store_all_events(fun), state}
  end

  @impl true
  def handle_call(:clear_table, _from, state) do
    ETS.clear_table()
    {:reply, :ok, state}
  end
end
