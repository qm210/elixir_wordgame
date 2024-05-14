# ElixirWordgame

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).



### Steps:
(prerequisites: current Erlang/OTP, Elixir, Mix, Phoenix 1.7.12 installed).
```
mix phx.new elixir_wordgame --live --database sqlite3

# can start already, start by the following, then check localhost:4000
mix phx.server
```

Comments:
* see the `deps/` folder, it's our `node_modules/` equivalent.
* see the assets > index.html -> basic JS scaffold
  * will not need to write more JS unless we want specialized stuff (Hooks, e.g. DnD, ...)
* This is a LiveView application due to `mix.exs`:
```
  {:phoenix_live_view, "~> 0.20.2"}
```
* history overview over Phoenix LiveView?
* see `elixir_wordgame` and `elixir_wordgame_web` directories
  * directory names are important
  * a lot of things are defined by convention

## Simple Live View
> Starting Commit: 062f84c

There is a CLI generator syntax `mix phx.gen.live ...` but we want to know what we're doing, so

* entry in router.ex
`live "/game", GameLive`
* -> requires the ElixirWordgameWeb.GameLive component
  * define `lib/elixir_wordgame_web/live/game_live.ex`
    * --> see basic version with only render and mount
    * `@time` is a socket assign and needs to be defined by the mount()

* for some structure, move the template content to `game_live.html.heex` next to `game_live.ex` and remove the `render/1` function 

## Display stuff dynamically
> From Commit: 747d93b

* new assigns
* template like that to interpolate content and style dynamically
```
<div class="word-display" style={"color: #{@color};"}>
    <%= @word %>
</div>
```

## Random words from list
```
word1 = Enum.random(words)
word2 = draw_different_word(word1, words)

defp draw_different_word(first_word, words) do
    result = Enum.random(words)
    if result != first_word, do: result, else: draw_different_word(first_word, words)
  end

```

## Centralize state -> GenServer
* for now, these LiveViews are different for each socket.
* GenServer for centralized state: `Game`
  * define init/1 and handle_call/3 and start_link/1
  * move application logic there
  * see game.ex in commit 
  * > 89759aa
* don't forget to put in the application.ex start children list!
* access from the liveview via
```
  def mount(_params, _session, socket) do
    state = GenServer.call(ElixirWordgame.Game, :get)
    IO.inspect state, label: "Mounting Initial State"
    {:ok, socket
          |> assign(word: state[:word])
          |> assign(color: state[:color])
    }
  end
```
* init/1 is called once per app startup only. can't GenServer.call(self(), ... ) due to recursive calls! 

## Simple Clock
> From commit 49a8347




### Postponed
* Ecto Integration (Database and Schemas) 


## General stuff
Language
* :atoms
* _unused convention is a rule
* function/1 notation -> i.e. like Python, Elixir is dynamically but strongly typed (no automatic type coercion, but a variable doesn't have an innate type)
  * "def" (public) and "defp" (private); but no nested functions
* last line is return value
* destructuring / everything is pattern-matching rather than assignment
  * focus on Immutability
  * i.e. there are no while-loops

Infra / Workflow
* no "npm install", rather "mix hex.info <package_name>" -> add manually -> "mix deps.get"
* Live Reloading on by default, but might look into configuration in case of wonders
* mix format