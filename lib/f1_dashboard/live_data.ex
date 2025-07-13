defmodule F1Dashboard.LiveData do
  @moduledoc """
  Public API for accessing cached F1 live data.
  """

  require Logger
  alias F1Dashboard.LiveData.Cache.Storage
  alias F1Dashboard.LiveData.{Session, SessionEvents, Driver}

  @type storage_result(t) :: {:ok, t} | {:error, :not_found}

  @spec get_session :: Session.t() | nil
  def get_session() do
    case Storage.get_session() do
      {:ok, session} ->
        session

      error ->
        Logger.warning("Failed to load session in the context: #{inspect(error)}")
        nil
    end
  end

  @spec get_events :: SessionEvents.t() | []
  def get_events() do
    case Storage.get_events() do
      {:ok, events} ->
        events

      error ->
        Logger.warning("Failed to load events in the context: #{inspect(error)}")
        nil
    end
  end

  @spec get_drivers() :: [Driver.t(), ...] | []
  def get_drivers() do
    case Storage.get_drivers() do
      {:ok, drivers} ->
        drivers

      error ->
        Logger.warning("Failed to load drivers in the context: #{inspect(error)}")
        nil
    end
  end
end
