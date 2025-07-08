defmodule F1Dashboard.Cache do
  @moduledoc """
  Public API for accessing cached F1 live data.
  """

  alias F1Dashboard.Cache.Storage
  alias F1Dashboard.LiveData.{Session, SessionEvents, Driver, DriverEvents}

  @type storage_result(t) :: {:ok, t} | {:error, :not_found}

  @spec get_session :: storage_result(Session.t())
  def get_session(), do: Storage.get_session()

  @spec get_events :: storage_result(SessionEvents.t())
  def get_events(), do: Storage.get_events()

  @spec get_driver(integer()) :: storage_result(Driver.t())
  def get_driver(driver_id), do: Storage.get_driver(driver_id)

  @spec get_driver_events() :: storage_result(DriverEvents.t())
  def get_driver_events(), do: Storage.get_driver_events()
end
