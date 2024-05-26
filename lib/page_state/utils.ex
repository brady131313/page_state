defmodule PageState.Utils do
  @moduledoc false
  def set_default_key(%{key: nil} = param) do
    {:ok, %{param | key: Atom.to_string(param.name)}}
  end

  def set_default_key(param), do: {:ok, param}

  def unique_by?(params, key) do
    names = Enum.map(params, &Map.get(&1, key))
    unique_names = Enum.uniq(names)

    length(names) == length(unique_names)
  end
end
