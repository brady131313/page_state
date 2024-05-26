defmodule PageState.VerifyUniqueParam do
  @moduledoc false
  use Spark.Dsl.Transformer

  alias PageState.Info
  alias PageState.Utils
  alias Spark.Dsl.Transformer

  @impl true
  def transform(dsl_state) do
    with {:ok, dsl_state} <- verify_top_level(dsl_state) do
      verify_nested(dsl_state)
    end
  end

  defp verify_top_level(dsl_state) do
    params = Transformer.get_entities(dsl_state, [:params])
    verify_unique(dsl_state, params)
  end

  defp verify_nested(dsl_state) do
    for %{params: params} <- Info.nested_params(dsl_state), reduce: {:ok, dsl_state} do
      {:ok, dsl_state} ->
        verify_unique(dsl_state, params)
    end
  end

  defp verify_unique(dsl_state, params) do
    cond do
      not Utils.unique_by?(params, :key) ->
        {:error,
         Spark.Error.DslError.exception(
           message: "parameter keys must be unique",
           module: Info.struct(dsl_state)
         )}

      not Utils.unique_by?(params, :name) ->
        {:error,
         Spark.Error.DslError.exception(
           message: "parameter names must be unique",
           module: Info.struct(dsl_state)
         )}

      true ->
        {:ok, dsl_state}
    end
  end
end
