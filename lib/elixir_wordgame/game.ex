defmodule ElixirWordgame.Game do
  use GenServer

  @registry_key :wordgame_client_registry

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_state) do
    # called on application startup
    Registry.start_link(name: @registry_key, keys: :unique)

    initial_state = draw_random()
    {:ok, initial_state}
  end

  def handle_call(:get, _from, state) do
    IO.inspect state, label: "Get - state"
    {:reply, state, state}
  end

  def handle_call(:draw_random, _from, state) do
    IO.inspect state, label: "Draw_Random State"
    new_state = draw_random()
    {:reply, new_state, new_state}
  end

  def handle_call(:increment, _from, state) do
    IO.inspect state, label: "Increment State"
    {:reply, :ok, state + 1}
  end

  @colors [
    "blue",
    "orange",
    "green",
    "red",
    "cyan",
    "magenta"
  ]

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