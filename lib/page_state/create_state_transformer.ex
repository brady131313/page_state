defmodule PageState.CreateStateTransformer do
  @moduledoc false
  use Spark.Dsl.Transformer

  alias PageState.Info
  alias Spark.Dsl.Transformer

  def after?(PageState.VerifyUniqueParam), do: true

  def transform(dsl_state) do
    state_module = Module.concat([Info.struct(dsl_state), State])

    nested_state_params_and_modules =
      dsl_state
      |> Info.nested_params()
      |> Enum.map(&{&1, create_nested_state_module(&1, state_module)})

    create_state_module(dsl_state, state_module, nested_state_params_and_modules)

    {:ok, dsl_state}
  end

  defp create_state_module(dsl_state, state_module, nested_state_params_and_modules) do
    attributes =
      dsl_state
      |> Transformer.get_entities([:params])
      |> Enum.map(& &1.name)

    params = Macro.escape(Info.params(dsl_state))
    nested_state_params_and_modules = Macro.escape(nested_state_params_and_modules)

    Module.create(
      state_module,
      quote do
        defstruct unquote(attributes)

        def decode(raw_params) do
          params = PageState.Utils.decode_params(raw_params, unquote(params))

          nested_params =
            for {nested_param, nested_module} <- unquote(nested_state_params_and_modules) do
              nested_params =
                raw_params
                |> Map.get(nested_param.key, %{})
                |> PageState.Utils.decode_params(nested_param.params)

              {nested_param.name, struct(nested_module, nested_params)}
            end

          struct(unquote(state_module), params ++ nested_params)
        end

        def encode(%state_module{} = state) do
        end
      end,
      Macro.Env.location(__ENV__)
    )
  end

  defp create_nested_state_module(nested_param, state_module) do
    nested_module_name =
      nested_param.name
      |> Atom.to_string()
      |> String.capitalize()

    nested_state_module = Module.concat([state_module, nested_module_name])
    attributes = Enum.map(nested_param.params, & &1.name)

    Module.create(
      nested_state_module,
      quote do
        defstruct unquote(attributes)
      end,
      Macro.Env.location(__ENV__)
    )

    nested_state_module
  end
end
