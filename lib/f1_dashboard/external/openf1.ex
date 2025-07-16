defmodule F1Dashboard.External.Openf1 do
  @moduledoc """
  Openf1 is an API which can be used to gather live and
  historical F1 Data. This module queries that API and returns
  the results.

  Official documentation can be found at: https://openf1.org/
  No Live data is provided when using the public API.
  You have to host their project yourself to receive the data.
  """

  def drivers(opts \\ []) do
    make_request("drivers", opts)
  end

  def intervals(opts \\ []) do
    make_request("intervals", opts)
  end

  def pit(opts \\ []) do
    make_request("pit", opts)
  end

  def position(opts \\ []) do
    make_request("position", opts)
  end

  def race_control(opts \\ []) do
    make_request("race_control", opts)
  end

  def session(opts \\ []) do
    make_request("sessions", opts)
  end

  def stints(opts \\ []) do
    make_request("stints", opts)
  end

  def weather(opts \\ []) do
    make_request("weather", opts)
  end

  defp make_request(path, params) do
    headers = [Accept: "Application/json; Charset=utf-8"]

    options = [
      timeout: :timer.seconds(5),
      recv_timeout: :timer.seconds(10),
      params: Enum.filter(params, &(elem(&1, 1) != nil))
    ]

    path
    |> build_url()
    |> do_request_and_decode(headers, options)
  end

  defp do_request_and_decode(url, headers, options) do
    case HTTPoison.get(url, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: _status_code} = reason} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_url(path) do
    base_url =
      Application.get_env(:f1_dashboard, __MODULE__)[:base_url]
      |> String.replace_suffix("/", "")

    "#{base_url}/v1/#{path}"
  end
end
