defmodule ElixirWordgame.Game do
  use GenServer

  @colors [
    "blue",
    "orange",
    "green",
    "red",
    "cyan",
    "magenta"
  ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_state) do
    # called on application startup
    initial_state = draw_random()
    {:ok, initial_state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_colors, _from, state) do
    {:reply, @colors, state}
  end

  def handle_call(:draw_random, _from, _state) do
    new_state = draw_random()
    {:reply, new_state, new_state}
  end

  def handle_call({:check_guess, guess}, _from, state) do
    if guess == state[:color] do
      new_state = draw_random()
      # yeah we don't have to wait, i just wanted to try.
      Process.send_after(self(), :publish_update, 0)
      {:reply, :success, new_state}
    else
      {:reply, :failure, state}
    end
  end

  # btw. difference: "call" blocks, "cast" doesn't but doesn't guarantee result.

  def handle_info(:publish_update, state) do
    message = {:fresh_drawn, state}
    Phoenix.PubSub.broadcast(ElixirWordgame.PubSub, "game_server", message)
    {:noreply, state}
  end

  def draw_random() do
    word = Enum.random(@colors)
    color = draw_different_word(word, @colors)
    %{word: word, color: color}
  end

  defp draw_different_word(first_word, words) do
    result = Enum.random(words)
    if result != first_word, do: result, else: draw_different_word(first_word, words)
  end
end
