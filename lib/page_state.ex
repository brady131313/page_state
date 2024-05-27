defmodule PageState do
  @moduledoc false
  use Spark.Dsl, default_extensions: [extensions: PageState.Dsl]

  defmacro __using__(opts) do
    {attach_hook?, opts} = Keyword.pop(opts, :attach_hook?, false)

    quote do
      unquote(super(opts))

      if unquote(attach_hook?) do
        require PageState.LiveView

        Code.ensure_compiled!(Phoenix.LiveView)
        PageState.LiveView.generate_on_mount(__MODULE__.State)
      end
    end
  end
end
