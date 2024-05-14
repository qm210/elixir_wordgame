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



### Postponed
* Ecto Integration (Database and Schemas) 


## General stuff
* last line is return value
* _unused convention is a rule
* no "npm install", rather "mix hex.info <package_name>" -> add manually -> "mix deps.get"