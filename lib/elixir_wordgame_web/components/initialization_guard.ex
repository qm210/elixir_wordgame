defmodule ElixirWordgame.InitializationGuard do
  use Phoenix.LiveComponent

  def render(assigns) do
    IO.inspect(assigns, label: "ASSIs")

    case assigns.initialized do
      true ->
        ~H"""
        <div style="display: contents">
          <%= render_slot(@inner_block) %>
        </div>
        """

      false ->
        ~H"""
        <h1 class="loading-title">
          Loading
        </h1>
        """
    end
  end
end
