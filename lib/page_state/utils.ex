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

  def decode_params(raw_params, params) do
    for param <- params do
      value =
        raw_params
        |> Map.get(param.key)
        |> cast_value(param.type)

      {param.name, value || param.default}
    end
  end

  defp cast_value(value, :string), do: value

  defp cast_value(value, :integer) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp cast_value("true", :boolean), do: true
  defp cast_value("false", :boolean), do: false

  defp cast_value(_, _type), do: nil
end
