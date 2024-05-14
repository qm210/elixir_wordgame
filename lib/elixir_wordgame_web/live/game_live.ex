defmodule ElixirWordgameWeb.GameLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    word = "blue"
    color = "green"
    {:ok, socket
          |> assign(time: 0)
          |> assign(word: word)
          |> assign(color: color)
    }
  end

end