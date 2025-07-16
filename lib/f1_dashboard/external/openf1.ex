defmodule F1Dashboard.External.Openf1 do
  @moduledoc """
  Openf1 is an API which can be used to gather live and
  historical F1 Data. This module queries that API and returns
  the results.

  Official documentation can be found at: https://openf1.org/
  No Live data is provided when using the public API.
  You have to host their project yourself to receive the data.
  """

  @timeout_after :timer.seconds(5)

  @retry_times 3
  @retry_delay_ms 100
  @retry_max_delay_ms 300

  def client() do
    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, base_url()},
        {Tesla.Middleware.DecodeJson, engine: Jason},
        {Tesla.Middleware.Logger, debug: false},
        {Tesla.Middleware.Timeout, timeout: @timeout_after},
        {Tesla.Middleware.Retry,
         delay: @retry_delay_ms,
         max_retries: @retry_times,
         max_delay: @retry_max_delay_ms,
         should_retry: fn
           {:ok, %{status: status}}, _env, _context when status in [400, 500] -> true
           {:ok, _reason}, _env, _context -> false
           {:error, _reason}, _env, _context -> true
         end}
      ],
      {Tesla.Adapter.Finch, name: MyFinch}
    )
  end

  def drivers(opts \\ []), do: make_request("drivers", opts)
  def intervals(opts \\ []), do: make_request("intervals", opts)
  def pit(opts \\ []), do: make_request("pit", opts)
  def position(opts \\ []), do: make_request("position", opts)
  def race_control(opts \\ []), do: make_request("race_control", opts)
  def session(opts \\ []), do: make_request("sessions", opts)
  def stints(opts \\ []), do: make_request("stints", opts)
  def weather(opts \\ []), do: make_request("weather", opts)

  defp make_request(path, params) do
    query_params = filter_params(params)

    case Tesla.get(client(), "/v1/#{path}", query: query_params) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status} = env} ->
        {:error, {:http_error, status, env}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp filter_params(params) do
    Enum.reject(params, fn {_key, value} -> is_nil(value) end)
  end

  defp base_url() do
    Application.get_env(:f1_dashboard, __MODULE__)[:base_url]
    |> String.replace_suffix("/", "")
  end
end
