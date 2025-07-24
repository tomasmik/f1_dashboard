defmodule F1Dashboard.LiveData.Workers.Race.Scheduler do
  require Logger

  alias F1Dashboard.LiveData.Workers.Race.State

  def schedule_after(_pid, _event, nil), do: :ok

  def schedule_after(pid, event, seconds) do
    Logger.info("Scheduling event #{event}, after #{seconds}s")
    Process.send_after(pid, event, :timer.seconds(seconds))
    :ok
  end

  def schedule_session_check(target_pid, %State{session_every: interval}) do
    schedule_after(target_pid, :check_session, interval)
  end

  def schedule_race_check(target_pid, %State{events_every: interval}) do
    schedule_after(target_pid, :check_events, interval)
  end
end
