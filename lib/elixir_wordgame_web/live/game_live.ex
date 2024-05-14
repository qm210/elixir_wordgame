defmodule ElixirWordgameWeb.GameLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    client_id = UUID.uuid4()
    Registry.register(:wordgame_client_registry, client_id, self())

    state = GenServer.call(ElixirWordgame.Game, :get)
    IO.inspect(socket, label: "Socket")
    {:ok, socket
          |> assign(word: state[:word])
          |> assign(color: state[:color])
          |> assign(clientId: client_id)
    }
  end

  def handle_event("send_user_input", %{"user_input" => guess}, socket) do
    IO.inspect(guess, label: "User Guesses:")
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    IO.inspect(socket, label: "Terminate Socket")
    client_id = socket.assigns.clientId
    IO.inspect(client_id, label: "client_id")
    Registry.unregister(:wordgame_client_registry, client_id, self())
    {:ok, socket}
  end

end