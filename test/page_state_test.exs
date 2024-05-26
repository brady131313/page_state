defmodule PageStateTest do
  use ExUnit.Case

  describe "to and from query string" do
    defmodule PageStateTest do
      use PageState

      params do
        param(:tab, :string)

        nested :feed1 do
          param(:page, :integer)
          param(:sort, :string)
        end

        nested :feed2 do
          param(:page, :integer)
          param(:sort, :string)
        end
      end
    end

    test "to query string" do
      IO.inspect(PageState.Info.nested_params(PageStateTest))
    end
  end

  test "defining an instance of the DSL works" do
    defmodule PageStateWorks do
      @moduledoc false
      use PageState

      params do
        param(:page_number, :integer)
        param(:type, :string, key: "type_key")

        nested(:nested_param) do
          key("nested_test")
          param(:page_number, :string)
        end
      end
    end

    assert PageState.Info.params(PageStateWorks) == [
             %PageState.Param{name: :page_number, type: :integer, key: "page_number"},
             %PageState.Param{name: :type, type: :string, key: "type_key"}
           ]

    assert PageState.Info.nested_params(PageStateWorks) == [
             %PageState.NestedParam{
               name: :nested_param,
               key: "nested_test",
               params: [
                 %PageState.Param{name: :page_number, type: :string, key: "page_number"}
               ]
             }
           ]
  end

  test "param names and nested param names do not conflict" do
    defmodule ParamAndNestedParamNameNoConflict do
      @moduledoc false
      use PageState

      params do
        param(:field1, :integer)

        nested(:nested_param) do
          param(:field1, :integer)
        end
      end
    end
  end

  test "param names must be unique" do
    assert_raise Spark.Error.DslError, ~r"parameter names must be unique", fn ->
      defmodule InvalidPageState do
        @moduledoc false
        use PageState

        params do
          param(:name, :string, key: "unique")
          param(:name, :string)
        end
      end
    end
  end

  test "param and nested names must be unique" do
    assert_raise Spark.Error.DslError, ~r"parameter names must be unique", fn ->
      defmodule InvalidPageState do
        @moduledoc false
        use PageState

        params do
          param(:name, :string, key: "unique")

          nested :name do
          end
        end
      end
    end
  end

  test "param keys must be unique" do
    assert_raise Spark.Error.DslError, ~r"parameter keys must be unique", fn ->
      defmodule InvalidPageState do
        @moduledoc false
        use PageState

        params do
          param(:field1, :string, key: "duplicate")
          param(:field2, :string, key: "duplicate")
        end
      end
    end
  end

  test "param and nested keys must be unique" do
    assert_raise Spark.Error.DslError, ~r"parameter keys must be unique", fn ->
      defmodule InvalidPageState do
        @moduledoc false
        use PageState

        params do
          param(:field1, :string, key: "duplicate")

          nested :nested do
            key("duplicate")
          end
        end
      end
    end
  end
end
