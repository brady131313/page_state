defmodule PageState.Type do
  @moduledoc false
  @callback cast(value :: String.t(), opts :: keyword()) :: term() | nil

  @callback dump(value :: term(), opts :: keyword()) :: String.t()
end
