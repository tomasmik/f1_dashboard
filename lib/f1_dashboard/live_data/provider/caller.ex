defmodule F1Dashboard.LiveData.Provider.Caller do
  alias F1Dashboard.LiveData
  alias F1Dashboard.External.Client

  alias LiveData.Provider.Transformer

  @spec session_latest() :: any()
  def session_latest() do
    make_opts()
    |> Client.session()
  end

  @spec drivers(F1Dashboard.LiveData.Session.t()) :: any()
  def drivers(%LiveData.Session{} = session) do
    make_opts(session)
    |> Client.drivers()
  end

  @spec race_control(F1Dashboard.LiveData.Session.t()) :: any()
  def race_control(%LiveData.Session{} = session) do
    make_opts(session)
    |> Client.race_control()
    |> Transformer.sort()
  end

  @spec intervals(F1Dashboard.LiveData.Session.t()) :: any()
  def intervals(%LiveData.Session{} = session) do
    make_opts(session)
    |> Client.intervals()
    |> Transformer.filter_for_last_driver()
  end

  @spec pit(F1Dashboard.LiveData.Session.t()) :: any()
  def pit(%LiveData.Session{} = session) do
    make_opts(session)
    |> Client.pit()
    |> Transformer.filter_for_last_driver()
  end

  @spec position(F1Dashboard.LiveData.Session.t()) :: any()
  def position(%LiveData.Session{} = session) do
    make_opts(session)
    |> Client.position()
    |> Transformer.filter_for_last_driver()
  end

  @spec stints(F1Dashboard.LiveData.Session.t()) :: any()
  def stints(%LiveData.Session{} = session) do
    make_opts(session)
    |> Client.stints()
    |> Transformer.filter_for_last_driver()
  end

  defp make_opts() do
    [session_key: "latest"]
  end

  defp make_opts(%LiveData.Session{} = session) do
    [session_key: session.session_key]
  end
end
