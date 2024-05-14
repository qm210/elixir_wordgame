defmodule ElixirWordgame.Clock do
  use GenServer

  def start_link(initial_state \\ 0) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def increment do
    GenServer.call(__MODULE__, :increment)
  end

  def init(state) do
    IO.inspect state, label: "Init"
    {:ok, state}
  end

  def handle_call(:get, from, state) do
    IO.inspect from, label: "Get From"
    IO.inspect state, label: "Get State"
    {:reply, state, state}
  end

  def handle_call(:increment, _from, state) do
    IO.inspect state, label: "Increment State"
    {:reply, :ok, state + 1}
  end

end