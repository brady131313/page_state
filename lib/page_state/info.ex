defmodule PageState.Info do
  @moduledoc false
  def struct(page_state) do
    Spark.Dsl.Extension.get_persisted(page_state, :module)
  end

  def params(page_state) do
    page_state
    |> Spark.Dsl.Extension.get_entities([:params])
    |> Enum.filter(&(&1.__struct__ == PageState.Param))
  end

  def nested_params(page_state) do
    page_state
    |> Spark.Dsl.Extension.get_entities([:params])
    |> Enum.filter(&(&1.__struct__ == PageState.NestedParam))
  end
end
