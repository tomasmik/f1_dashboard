defmodule F1Dashboard.LiveData.Cache.ETS do
  require Logger

  @table_name :f1_data

  alias F1Dashboard.LiveData.{Session, SessionEvents, Driver}

  @type cache_result(t) :: {:ok, t} | {:error, :not_found}
  @type driver :: Driver.t()
  @type drivers :: [Driver.t(), ...]
  @type events :: SessionEvents.t()
  @type session :: Session.t()

  def init() do
    :ets.new(@table_name, [
      :set,
      :protected,
      :named_table,
      {:read_concurrency, true}
    ])
  end

  @spec get_session() :: cache_result(session())
  def get_session() do
    case :ets.lookup(@table_name, :session) do
      [{:session, session}] -> {:ok, session}
      [] -> {:error, :not_found}
    end
  end

  @spec get_events() :: cache_result(events())
  def get_events() do
    case :ets.lookup(@table_name, :events) do
      [{:events, events}] -> {:ok, events}
      [] -> {:error, :not_found}
    end
  end

  @spec get_driver(integer()) :: cache_result(driver())
  def get_driver(driver_id) do
    case :ets.lookup(@table_name, {:driver, driver_id}) do
      [{:driver, ^driver_id, driver}] -> {:ok, driver}
      [] -> {:error, :not_found}
    end
  end

  @spec get_drivers() :: cache_result([driver(), ...])
  def get_drivers() do
    case :ets.match(@table_name, {{:driver, :"$1"}, :"$2"}) do
      [] ->
        {:error, :not_found}

      matches ->
        events = Enum.map(matches, fn [_driver_number, event] -> event end)
        {:ok, events}
    end
  end

  def store_drivers(drivers) do
    drivers
    |> Enum.each(fn driver ->
      :ets.insert(@table_name, {{:driver, driver.driver_number}, driver})
    end)

    Logger.info("Update to drivers data in the cache")
  end

  def store_session(session) do
    :ets.insert(@table_name, {:session, session})
    Logger.info("Update to session data in the cache")
  end

  def store_all_events(events) do
    :ets.insert(@table_name, {:events, events})
    Logger.info("Update to events data in the cache")
  end

  def clear_table() do
    Logger.info("Cleaning up the cache, will remove all data")
    :ets.delete_all_objects(@table_name)
  end
end
