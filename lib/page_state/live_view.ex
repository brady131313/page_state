defmodule PageState.LiveView do
  defmacro generate_on_mount(page_state) do
    quote do
      require Phoenix.LiveView

      Phoenix.LiveView.on_mount({__MODULE__, :param_hook})

      def on_mount(:param_hook, params, session, socket) do
        socket =
          Phoenix.LiveView.attach_hook(socket, :page_state_param_hook, :handle_params, fn params, _uri, socket ->
            state = unquote(page_state).decode(params)
            {:cont, Phoenix.Component.assign(socket, page_state: state)}
          end)

        state = unquote(page_state).decode(params)
        {:cont, Phoenix.Component.assign(socket, page_state: state)}
      end

      def encode_page_state(state) do
        unquote(page_state).encode(state)
      end
    end
  end
end
