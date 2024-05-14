defmodule ElixirWordgameWeb.GameLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    state = GenServer.call(ElixirWordgame.Game, :get)
    {:ok, socket
          |> assign(word: state[:word])
          |> assign(color: state[:color])
    }
  end

end