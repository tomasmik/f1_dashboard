defmodule F1Dashboard.LiveData.Provider.Caller do
  alias F1Dashboard.LiveData
  alias F1Dashboard.External.Client

  alias LiveData.Provider.Transformer

  alias LiveData.Session

  @spec session_latest() :: {:ok, map()} | {:error, any()}
  def session_latest() do
    make_opts()
    |> Client.session()
    |> Transformer.get_one()
  end

  @spec drivers(map()) :: {:ok, list()} | {:error, any()}
  def drivers(session) do
    make_opts(session)
    |> Client.drivers()
  end

  @spec race_control(Session.t()) :: {:ok, list()} | {:error, any()}
  def race_control(%Session{} = session) do
    make_opts(session)
    |> Client.race_control()
    |> Transformer.sort_by_date()
  end

  @spec weather(Session.t()) :: {:ok, map()} | {:error, any()}
  def weather(%Session{} = session) do
    make_opts(session)
    |> Client.weather()
    |> Transformer.get_last()
  end

  @spec intervals(Session.t()) :: {:ok, list()} | {:error, any()}
  def intervals(%Session{} = session) do
    make_opts(session)
    |> Client.intervals()
    |> Transformer.filter_for_last_driver()
    |> Transformer.filter_outdated_events()
  end

  @spec pit(Session.t()) :: {:ok, list()} | {:error, any()}
  def pit(%Session{} = session) do
    make_opts(session)
    |> Client.pit()
    |> Transformer.filter_for_last_driver()
  end

  @spec position(Session.t()) :: {:ok, list()} | {:error, any()}
  def position(%Session{} = session) do
    make_opts(session)
    |> Client.position()
    |> Transformer.filter_for_last_driver()
    |> Transformer.sort_by_position()
  end

  @spec stints(Session.t()) :: {:ok, list()} | {:error, any()}
  def stints(%Session{} = session) do
    make_opts(session)
    |> Client.stints()
    |> Transformer.filter_for_last_driver()
  end

  defp make_opts() do
    [session_key: "latest"]
  end

  defp make_opts(%Session{} = session) do
    [session_key: session.session_key]
  end

  defp make_opts(session) when is_map(session) do
    session_key = session["session_key"] || session[:session_key]
    [session_key: session_key]
  end
end
