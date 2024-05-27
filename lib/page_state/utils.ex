defmodule PageState.Utils do
  @moduledoc false

  alias PageState.Param

  def transform_param(%Param{} = param) do
    with {:ok, param} <- set_default_key(param) do
      set_valid_options(param)
    end
  end

  def set_default_key(%{key: nil} = param) do
    {:ok, %{param | key: Atom.to_string(param.name)}}
  end

  def set_default_key(%{} = param), do: {:ok, param}

  def set_valid_options(%Param{type: {:one_of, options}} = param) do
    options = Enum.map(options, &to_string/1)
    {:ok, %{param | options: options}}
  end

  def set_valid_options(%Param{} = param), do: {:ok, param}

  def unique_by?(params, key) do
    names = Enum.map(params, &Map.get(&1, key))
    unique_names = Enum.uniq(names)

    length(names) == length(unique_names)
  end

  def encode_params(state, params) do
    for param <- params do
      value = Map.get(state, param.name)
      {param.key, to_string(value)}
    end
  end

  def decode_params(raw_params, params) do
    for param <- params do
      value =
        raw_params
        |> Map.get(param.key)
        |> cast_value(param)
        |> case do
          nil -> param.default
          value -> value
        end

      {param.name, value}
    end
  end

  defp cast_value(value, %Param{type: :string}), do: value

  defp cast_value(value, %Param{type: :integer}) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp cast_value("true", %Param{type: :boolean}), do: true
  defp cast_value("false", %Param{type: :boolean}), do: false

  defp cast_value(value, %Param{type: {:one_of, [head | _]}, options: str_options}) when is_atom(head) do
    if value in str_options do
      String.to_existing_atom(value)
    end
  end

  defp cast_value(value, %Param{type: {:one_of, _options}, options: str_options}) do
    if value in str_options do
      value
    end
  end

  defp cast_value(_, _type), do: nil
end
