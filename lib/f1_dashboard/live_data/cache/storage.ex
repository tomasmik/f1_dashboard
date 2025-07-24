defmodule F1Dashboard.LiveData.Cache.Storage do
  @moduledoc """
  Storage is a generic behavior which can be used to store
  cache data.
  """

  alias F1Dashboard.LiveData.{SessionData, SessionEvents}

  @type cache_result(t) :: {:ok, t} | {:error, :not_found}
  @type events :: SessionEvents.t()
  @type session_data :: SessionData.t()

  @callback init() :: any()
  @callback get_session_data() :: cache_result(session_data())
  @callback get_events() :: cache_result(events())
  @callback store_session_data(session_data()) :: {:ok, atom()} | {:error, any()}
  @callback store_all_events(function()) :: {:ok, atom()} | {:error, any()}
  @callback clear() :: any()
end
