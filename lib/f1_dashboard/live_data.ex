defmodule F1Dashboard.LiveData do
  @moduledoc """
  Public API for accessing and manipulating cached F1 live data.
  """

  require Logger

  alias Phoenix.PubSub

  alias F1Dashboard.Topics
  alias F1Dashboard.LiveData.Cache.Storage
  alias F1Dashboard.LiveData.{SessionData, SessionEvents}

  @type storage_result(t) :: {:ok, t} | {:error, :not_found}

  @spec get_session_data :: SessionData.t() | nil
  def get_session_data() do
    Storage.get_session_data()
    |> result_or_default(nil)
  end

  @spec get_events :: SessionEvents.t()
  def get_events() do
    Storage.get_events()
    |> result_or_default(%SessionEvents{})
  end

  def subscribe() do
    PubSub.subscribe(F1Dashboard.PubSub, Topics.session())
    PubSub.subscribe(F1Dashboard.PubSub, Topics.events())
  end

  defp result_or_default({:error, any}, default) do
    Logger.warning("Failed to load data: #{inspect(any)}")
    default
  end

  defp result_or_default({:ok, value}, _), do: value
end
