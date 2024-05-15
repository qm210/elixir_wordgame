defmodule ElixirWordgameWeb.GameLive do
  use Phoenix.LiveView

  @session_storage_key "elixir.wordgame.store"

  def mount(_params, _session, socket) do
    client_id = UUID.uuid4()

    if connected?(socket) do
      Phoenix.PubSub.subscribe(ElixirWordgame.PubSub, "game_server")
    end

    defined_colors = GenServer.call(ElixirWordgame.Game, :get_colors)
    state = GenServer.call(ElixirWordgame.Game, :get)

    {:ok,
     socket
     |> assign(word: state[:word])
     |> assign(color: state[:color])
     |> assign(clientId: client_id)
     |> assign(points: 0)
     |> assign(definedColors: defined_colors)
     |> assign(initialized: false)
     |> initialize_session()}
  end

  defp initialize_session(socket) do
    if connected?(socket) do
      push_event(
        socket,
        "session_load",
        %{key: @session_storage_key, event: "hydrate"}
      )
    else
      socket
    end
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

  def handle_event("hydrate", stored_session, socket) do
    case stored_session do
      nil ->
        {:noreply,
         socket
         |> initialize_new_session()
         |> assign(initialized: true)}

      %{"id" => id} ->
        {:noreply,
         socket
         |> assign(clientId: id)
         |> assign(initialized: true)}

      _ ->
        IO.inspect(stored_session, label: "Cannot Parse Session Format")
        {:noreply, socket}
    end
  end

  defp initialize_new_session(socket) do
    # not much in there, for now just our id
    store = %{id: socket.assigns.clientId}

    socket
    |> push_event(
      "session_store",
      %{key: @session_storage_key, data: store}
    )
  end

  def handle_info({:fresh_drawn, new_values}, socket) do
    {:noreply,
     socket
     |> assign(word: new_values[:word])
     |> assign(color: new_values[:color])
     |> push_event("reset_input_field", %{})}
  end

  def terminate(_reason, socket) do
    _client_id = socket.assigns.clientId
    {:ok, socket}
  end
end
