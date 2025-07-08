defmodule F1Dashboard.External.Openf1 do
  require Logger

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
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: _status_code} = reason} ->
        {:error, reason}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_url(path) do
    base_url = Application.get_env(:f1_dashboard, __MODULE__)[:base_url]

    if !base_url do
      Logger.warning("No base url for openf1 API set, did you configure the env variables?")
    end

    "#{base_url}/v1/#{path}"
  end
end
