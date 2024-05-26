defmodule PageState.CreateStateTransformer do
  @moduledoc false
  use Spark.Dsl.Transformer

  alias PageState.Info
  alias Spark.Dsl.Transformer

  def transform(dsl_state) do
    attributes =
      dsl_state
      |> Transformer.get_entities([:params])
      |> Enum.map(& &1.name)

    state_module = Module.concat([Info.struct(dsl_state), State])
    create_module(state_module, attributes)

    nested_params = Info.nested_params(dsl_state)

    for nested_param <- nested_params do
      nested_module_name =
        nested_param.name
        |> Atom.to_string()
        |> String.capitalize()

      nested_state_module = Module.concat([state_module, nested_module_name])
      attributes = Enum.map(nested_param.params, & &1.name)

      create_module(nested_state_module, attributes)
    end

    {:ok, dsl_state}
  end

  def create_module(module, attributes) do
    Module.create(
      module,
      quote do
        defstruct unquote(attributes)
      end,
      Macro.Env.location(__ENV__)
    )
  end

  def after?(PageState.VerifyUniqueParam), do: true
end
