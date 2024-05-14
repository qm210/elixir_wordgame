defmodule ElixirWordgameWeb.GameLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    client_id = UUID.uuid4()
    # Registry.register(:wordgame_client_registry, client_id, self())
    if connected?(socket) do
      Phoenix.PubSub.subscribe(ElixirWordgame.PubSub, "game_server")
    end

    state = GenServer.call(ElixirWordgame.Game, :get)
    {:ok, socket
          |> assign(word: state[:word])
          |> assign(color: state[:color])
          |> assign(clientId: client_id)
          |> assign(points: 0)
    }
  end

  def handle_event("send_user_input", %{"user_input" => guess}, socket) do
    checked_guess = GenServer.call(ElixirWordgame.Game, {:check_guess, guess})
    case checked_guess do
      :success ->
        {:noreply, socket |> assign(points: socket.assigns.points + 1)}
      :failure ->
        {:noreply, socket}
    end
  end

  # btw. difference: "call" blocks, "cast" doesn't but doesn't guarantee result.

  def handle_info({:fresh_drawn, new_values}, socket) do
    {:noreply, socket
               |> assign(word: new_values[:word])
               |> assign(color: new_values[:color])
    }
  end

  def terminate(_reason, socket) do
    _client_id = socket.assigns.clientId
    # Registry.unregister(:wordgame_client_registry, client_id, self())
    {:ok, socket}
  end

end