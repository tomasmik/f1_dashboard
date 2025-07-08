defmodule F1Dashboard.Helpers.Data do
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
  def normalize(data, schema) do
    schema.changeset(data)
    |> Ecto.Changeset.apply_action(:insert)
  end
end
