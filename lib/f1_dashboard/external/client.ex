defmodule F1Dashboard.External.Client do
  @callback drivers(keyword()) :: {:ok, [map()]} | {:error, any()}
  @callback intervals(keyword()) :: {:ok, [map()]} | {:error, any()}
  @callback pit(keyword()) :: {:ok, [map()]} | {:error, any()}
  @callback position(keyword()) :: {:ok, [map()]} | {:error, any()}
  @callback race_control(keyword()) :: {:ok, [map()]} | {:error, any()}
  @callback session(keyword()) :: {:ok, [map()]} | {:error, any()}
  @callback stints(keyword()) :: {:ok, [map()]} | {:error, any()}
  @callback weather(keyword()) :: {:ok, [map()]} | {:error, any()}

  def drivers(opts \\ []), do: impl().drivers(opts)
  def intervals(opts \\ []), do: impl().intervals(opts)
  def pit(opts \\ []), do: impl().pit(opts)
  def position(opts \\ []), do: impl().position(opts)
  def race_control(opts \\ []), do: impl().race_control(opts)
  def session(opts \\ []), do: impl().session(opts)
  def stints(opts \\ []), do: impl().stints(opts)
  def weather(opts \\ []), do: impl().weather(opts)

  defp impl, do: Application.get_env(:f1_dashboard, :api, F1Dashboard.External.Openf1)
end
