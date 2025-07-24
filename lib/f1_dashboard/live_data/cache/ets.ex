defmodule F1Dashboard.LiveData.Cache.ETS do
  @behaviour F1Dashboard.LiveData.Cache.Storage

  require Logger

  @table_name :f1_data

  alias F1Dashboard.LiveData.SessionData
  alias Phoenix.PubSub
  alias F1Dashboard.Topics
  alias F1Dashboard.LiveData.{SessionData, SessionEvents}

  @type cache_result(t) :: {:ok, t} | {:error, :not_found}
  @type events :: SessionEvents.t()
  @type session :: SessionData.t()

  @impl true
  def init() do
    :ets.new(@table_name, [
      :set,
      :protected,
      :named_table,
      {:read_concurrency, true}
    ])
  end

  @impl true
  def get_session_data() do
    case :ets.lookup(@table_name, :session) do
      [{:session, session}] -> {:ok, session}
      [] -> {:error, :not_found}
    end
  end

  @impl true
  def get_events() do
    case :ets.lookup(@table_name, :events) do
      [{:events, events}] -> {:ok, events}
      [] -> {:error, :not_found}
    end
  end

  @impl true
  def store_session_data(session) do
    case status = insert_if_changed(:session, session) do
      :updated ->
        :ets.delete(@table_name, :events)
        PubSub.broadcast(F1Dashboard.PubSub, Topics.session(), {:session_updated, session})
        PubSub.broadcast(F1Dashboard.PubSub, Topics.events(), {:events_updated, []})
        Logger.info("Update to session data in the cache")
        {:ok, status}

      :unchanged ->
        Logger.info("No new session data was written")
        {:ok, status}
    end
  end

  @impl true
  def store_all_events(fun) when is_function(fun, 1) do
    with {:ok, session} <- get_session_data(),
         {:ok, events} <- fun.(session),
         status <- insert_if_changed(:events, events) do
      case status do
        :updated ->
          PubSub.broadcast(F1Dashboard.PubSub, Topics.events(), {:events_updated, events})
          Logger.info("Update to events data in the cache")

        :unchanged ->
          Logger.info("No new events data was written")
      end

      {:ok, status}
    else
      error ->
        error
    end
  end

  @impl true
  def clear() do
    Logger.info("Cleaning up the cache, will remove all data")
    :ets.delete_all_objects(@table_name)
  end

  defp insert_if_changed(key, value) do
    case :ets.lookup(@table_name, key) do
      [] ->
        :ets.insert(@table_name, {key, value})
        :updated

      [{^key, existing_value}] when existing_value == value ->
        :unchanged

      _ ->
        :ets.insert(@table_name, {key, value})
        :updated
    end
  end
end
