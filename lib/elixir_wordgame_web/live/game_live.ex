defmodule ElixirWordgameWeb.GameLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
      <div>
        <h1>Current Time: <%= @time %></h1>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, time: 0)}
  end

end