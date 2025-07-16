defmodule F1Dashboard.Helpers.Data do
  @moduledoc """
  Data is a helper module for dealing with data we've received.

  It's a rather dumb module with dumb functions as we mostly
  cannot do much when the data is bad. It's a bug that needs
  to be fixed in the code, best we can do it report it.
  """

  @spec normalize([map()], module()) :: {:ok, [struct()]} | {:error, any()}
  def normalize(data, schema) when is_list(data) do
    case Enum.reduce_while(data, [], fn item, acc ->
           case normalize(item, schema) do
             {:ok, normalized} ->
               {:cont, [normalized | acc]}

             {:error, _} = error ->
               {:halt, error}
           end
         end) do
      {:error, _} = error -> error
      normalized -> {:ok, Enum.reverse(normalized)}
    end
  end

  @spec normalize(map(), module()) :: {:ok, struct()} | {:error, any()}
  def normalize(data, schema) when is_map(data) do
    case schema.changeset(data) |> Ecto.Changeset.apply_action(:insert) do
      {:ok, data} ->
        {:ok, data}

      {:error, changeset} ->
        readable_errors(changeset)
    end
  end

  defp readable_errors(%Ecto.Changeset{} = changeset) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    {:error, errors}
  end
end
