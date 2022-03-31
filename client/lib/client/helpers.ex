defmodule Client.Helpers do
  def key_to_atom(map) do
    Enum.reduce(map, %{}, fn
      # String.to_existing_atom saves us from overloading the VM by
      # creating too many atoms. It'll always succeed because all the fields
      # in the database already exist as atoms at runtime.
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end

  def recursive_keys_to_atom(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map,
        into: %{},
        do: {String.to_atom(key), recursive_keys_to_atom(val)}
  end

  def recursive_keys_to_atom(string_key_list) when is_list(string_key_list) do
    string_key_list
    |> Enum.map(&recursive_keys_to_atom/1)
  end

  def recursive_keys_to_atom(value), do: value
end
