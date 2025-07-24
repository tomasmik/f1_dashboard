defmodule F1Dashboard.LiveData.Supervisor do
  use Supervisor

  alias F1Dashboard.LiveData

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      LiveData.Cache,
      LiveData.Workers.Race
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
