defmodule PageStateTest do
  use ExUnit.Case

  describe "encodes and decodes into same data" do
    defmodule EncodeDecodeTest do
      use PageState, attach_hook?: true

      params do
        param(:string_key, :string, key: "some_string")
        param(:integer_key, :integer, key: "some_integer")
        param(:boolean_key, :boolean, key: "some_boolean")

        param(:string_choice, {:one_of, ["choice_one", "choice_two"]}, key: "some_string_choice")
        param(:atom_choice, {:one_of, [:other_one, :other_two]}, key: "some_atom_choice")

        nested :nested_key do
          key("some_nested")
          param(:nested_string_key, :string, key: "nested_string")
          param(:nested_integer_key, :integer, key: "nested_integer")
          param(:nested_boolean_key, :boolean, key: "nested_boolean")
        end
      end
    end

    test "it works" do
      state = %EncodeDecodeTest.State{
        string_key: "string",
        integer_key: 42,
        boolean_key: true,
        string_choice: "choice_one",
        atom_choice: :other_one,
        nested_key: %EncodeDecodeTest.State.NestedKey{
          nested_string_key: "nested string",
          nested_integer_key: 24,
          nested_boolean_key: false
        }
      }

      assert state
             |> EncodeDecodeTest.State.encode()
             |> EncodeDecodeTest.State.decode() == state
    end

    test "defines on mount hook" do
      assert function_exported?(EncodeDecodeTest, :on_mount, 4)
    end
  end

  describe "to and from query string" do
    defmodule PageStateTestData do
      @moduledoc false
      use PageState

      params do
        param(:tab, :string)

        nested :feed1 do
          param(:page, :integer)
          param(:sort, :string)

          param(:sort_dir, :string) do
            default("asc")
          end
        end

        nested :feed2 do
          param(:page, :integer)
          param(:sort, :string)
        end
      end
    end

    test "decode page state" do
      raw_params = %{
        "tab" => "feed",
        "feed1" => %{
          "page" => "1",
          "sort" => "first"
        },
        "feed2" => %{
          "page" => "2",
          "sort" => "other"
        }
      }

      assert %PageStateTestData.State{
               tab: "feed",
               feed1: %PageStateTestData.State.Feed1{
                 page: 1,
                 sort: "first",
                 sort_dir: "asc"
               },
               feed2: %PageStateTestData.State.Feed2{
                 page: 2,
                 sort: "other"
               }
             } == PageStateTestData.State.decode(raw_params)
    end

    test "encode page state" do
      state = %PageStateTestData.State{
        tab: "feed",
        feed1: %PageStateTestData.State.Feed1{
          page: 1,
          sort: "first",
          sort_dir: "asc"
        },
        feed2: %PageStateTestData.State.Feed2{
          page: 2,
          sort: "other"
        }
      }

      assert %{
               "tab" => "feed",
               "feed1" => %{
                 "page" => "1",
                 "sort" => "first",
                 "sort_dir" => "asc"
               },
               "feed2" => %{
                 "page" => "2",
                 "sort" => "other"
               }
             } == PageStateTestData.State.encode(state)
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

    assert PageState.Dsl.Info.params(PageStateWorks) == [
             %PageState.Dsl.Param{name: :page_number, type: :integer, key: "page_number"},
             %PageState.Dsl.Param{name: :type, type: :string, key: "type_key"}
           ]

    assert PageState.Dsl.Info.nested_params(PageStateWorks) == [
             %PageState.Dsl.NestedParam{
               name: :nested_param,
               key: "nested_test",
               params: [
                 %PageState.Dsl.Param{name: :page_number, type: :string, key: "page_number"}
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

  describe "custom types" do
    defmodule CustomType do
      @moduledoc false

      @behaviour PageState.Type

      @impl true
      def cast("fourty-two", _opts) do
        42
      end

      @impl true
      def dump(42, _opts) do
        "fourty-two"
      end
    end

    defmodule PageStateCustomType do
      @moduledoc false
      use PageState

      params do
        param(:custom, {CustomType, value: 42})
      end
    end

    test "it works" do
      assert PageState.Dsl.Info.params(PageStateCustomType) == [
               %PageState.Dsl.Param{name: :custom, key: "custom", type: {CustomType, value: 42}}
             ]

      raw_params = %{"custom" => "fourty-two"}

      decoded = PageStateCustomType.State.decode(raw_params)
      assert %PageStateCustomType.State{custom: 42} == decoded

      encoded = PageStateCustomType.State.encode(decoded)
      assert raw_params == encoded
    end
  end
end
