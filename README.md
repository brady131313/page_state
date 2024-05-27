# PageState

PageState is a library to declaratively define the state of a webpage. It uses Spark to create a DSL for defining the state of a page and a way to encode and decode that state to and from a string keyed map.

## Motivation

Often in a LiveView application some portion of the page state is stored in the url as query params (pagination, filters, etc). When patching the url to show a modal, we may want to preserve the pagination or filter state behind the modal so a table in the background doesn't have content popping in and out. Decoding and encoding these query params is repetitive and patching the url again while maintaining the current state is error prone.

## Usage

### Declare the page state params

```elixir
defmodule DashboardLive do
  use PageState

  params do
    param :query, :string do
      key "q"
    end

    param :include_count, :boolean, default: false
    param :category, {:one_of, [:a, :b, :c]}, default: :a

    nested :task_section do
      key "t"
      param :page_number, :integer, default: 1
      param :page_size, :integer, default: 10
      param :sort_dir, {:one_of, [:asc, :desc]}, default: :asc
    end
  end
end
```

### Decode string keyed map

```elixir
DashboardLive.State.decode(%{
  "q" => "some search",
  "include_count" => "true",
  "t" => %{
    "page_number" => "2",
    "page_size" => "20",
  }
})
```

### Encode state to string keyed map

```elixir
DashboardLive.State.encode(%DashboardLive.State{
  query: "some search",
  include_count: true,
  category: :b,
  task_section: %DashboardLive.State.TaskSection{
    page_number: 2,
    page_size: 20,
    sort_dir: :desc
  }
})
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `page_state` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:page_state, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/page_state>.
