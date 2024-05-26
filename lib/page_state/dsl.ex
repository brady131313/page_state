param_schema = [
  name: [
    type: :atom,
    required: true,
    doc: "the name of the parameter"
  ],
  type: [
    type: {:one_of, [:string, :integer, :boolean]},
    required: true,
    doc: "the type the paramter should be cast to"
  ],
  key: [
    type: :string,
    doc: "the key to use in the query string"
  ]
]

param = %Spark.Dsl.Entity{
  name: :param,
  describe: "parameter stored in a query string",
  target: PageState.Param,
  schema: param_schema,
  args: [:name, :type],
  transform: {PageState.Utils, :set_default_key, []}
}

nested_param_schema = [
  name: [
    type: :atom,
    required: true,
    doc: "the name of the parameter"
  ],
  key: [
    type: :string,
    doc: "the key to use in the query string"
  ]
]

nested_param = %Spark.Dsl.Entity{
  name: :nested,
  describe: "Adds a nested parameter stored in a query string",
  target: PageState.NestedParam,
  schema: nested_param_schema,
  args: [:name],
  transform: {PageState.Utils, :set_default_key, []},
  entities: [params: [param]]
}

params = %Spark.Dsl.Section{
  name: :params,
  describe: """
    Declare the parameters that are stored in a query string
  """,
  entities: [
    param,
    nested_param
  ]
}

defmodule PageState.Dsl do
  @moduledoc false
  use Spark.Dsl.Extension,
    sections: [params],
    transformers: [
      PageState.VerifyUniqueParam
    ]
end
