defmodule PageState do
  @moduledoc false
  use Spark.Dsl, default_extensions: [extensions: PageState.Dsl]

  defmacro __using__(opts) do
    {attach_hook?, opts} = Keyword.pop(opts, :attach_hook?, false)

    if attach_hook? do
      Code.ensure_compiled!(Phoenix.LiveView)

      quote do
        require PageState.LiveView

        PageState.LiveView.generate_on_mount(__MODULE__.State)
      end
    end

    super(opts)
  end
end
