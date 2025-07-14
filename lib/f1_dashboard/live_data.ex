defmodule F1Dashboard.LiveData do
  @moduledoc """
  Public API for accessing and manipulating cached F1 live data.
  """

  require Logger

  alias Phoenix.PubSub

  alias F1Dashboard.Topics
  alias F1Dashboard.LiveData.Cache.Storage
  alias F1Dashboard.LiveData.{Session, SessionEvents, Driver}

  @type storage_result(t) :: {:ok, t} | {:error, :not_found}

  @spec get_session :: Session.t() | nil
  def get_session() do
    Storage.get_session()
    |> Storage.result_or_default(nil)
  end

  @spec get_events :: SessionEvents.t() | []
  def get_events() do
    Storage.get_events()
    |> Storage.result_or_default([])
  end

  @spec get_drivers() :: [Driver.t(), ...] | []
  def get_drivers() do
    Storage.get_drivers()
    |> Storage.result_or_default([])
  end

  def subscribe() do
    PubSub.subscribe(F1Dashboard.PubSub, Topics.session())
    PubSub.subscribe(F1Dashboard.PubSub, Topics.drivers())
    PubSub.subscribe(F1Dashboard.PubSub, Topics.events())
  end
end
