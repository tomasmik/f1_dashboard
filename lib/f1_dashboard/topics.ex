defmodule F1Dashboard.Topics do
  @moduledoc """
  This is a simple module for all the possible pubsub topics.
  It should be used when subscribing or publishing messages.
  """
  @spec events :: String.t()
  def events, do: "events:all"

  @spec session :: String.t()
  def session, do: "session:all"

  @spec drivers :: String.t()
  def drivers, do: "drivers:all"
end
