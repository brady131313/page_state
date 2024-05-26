defmodule PageState do
  @moduledoc false
  use Spark.Dsl,
    default_extensions: [extensions: PageState.Dsl]

  defmacro __using__(opts) do
    super(opts)
  end
end
