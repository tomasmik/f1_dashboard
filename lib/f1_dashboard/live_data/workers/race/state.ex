defmodule F1Dashboard.LiveData.Workers.Race.State do
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

  def update_session_change(_, :updated), do: default()
  def update_session_change(%__MODULE__{} = state, _), do: state

  def update_events_change(_, :updated), do: default()

  def update_events_change(%__MODULE__{} = state, _) do
    got = min(@maximum_race_every, state.events_every * 2)
    %{state | events_every: got}
  end
end
