defmodule F1Dashboard.Cache.WorkerState do
  defstruct session_ready: false, session_every: 1, events_every: 1

  @no_session_every 2

  @default_session_every 300
  @default_race_every 5

  @maximum_race_every 120

  def default() do
    %__MODULE__{
      session_ready: true,
      session_every: @default_session_every,
      events_every: @default_race_every
    }
  end

  def init() do
    %__MODULE__{
      session_ready: false,
      session_every: @no_session_every,
      events_every: @default_race_every
    }
  end

  def update_session_change(%__MODULE__{} = state, old, new) do
    session_changed(state, !two_events_equal?(old, new))
  end

  def update_events_change(%__MODULE__{} = state, old, new) do
    events_changed(state, !two_events_equal?(old, new))
  end

  defp two_events_equal?(old_events, new_events) do
    calculate_checksum(old_events) == calculate_checksum(new_events)
  end

  defp calculate_checksum(events) do
    events
    |> :erlang.term_to_binary()
    |> :erlang.md5()
    |> Base.encode16()
  end

  defp events_changed(_state, true), do: default()

  defp events_changed(state, false) do
    got = min(@maximum_race_every, state.events_every * 2)
    %{state | events_every: got}
  end

  defp session_changed(_state, true), do: default()
  defp session_changed(state, false), do: state
end
