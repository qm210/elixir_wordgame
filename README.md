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
* the three return values are e.g. {:reply, return_value, new_state} or {:error, ...}

## User Input
> From commit 216e94a
* Use a simple form that submits on Enter, we would need JS for more custom event handling
* needs the `phx-submit` attribute, e.g. might look like
```
<form phx-submit="send_user_input">
    <input autofocus name="user_input"/>
</form>
```
* can run even when not defined in the backend, will crash the frontend (see stacktrace in backend) but not the app (auto reload liveview) 
* but define this in the LiveView and so Enter won't crash the page anymore
```
  def handle_event("send_user_input", %{"user_input" => guess}, socket) do
    IO.inspect(guess, label: "User Guesses:")
    {:noreply, socket}
  end
  ```

## Broadcasting Updates
> see Commit 07b63d1


# Reset the Form from the LiveView: Hooks.
* Hooks (custom JS interactions)
```
document.addEventListener("DOMContentLoaded", () => {
  let Hooks = {}
  Hooks.ForceInputValue = {
    mounted() {
      this.el.addEventListener("phx-force-input-value", (event) => {
        this.el.value = event.detail.value;
      });
    },
  };
```

## Unclear: Update Behaviour
* entering the correct name resets the field
* entering a wrong name doesn't reset the field (unless I also change the socket assigns in the :failure case)
* is that general behaviour? 
* Seems like the Input Field can't be reset by the socket assign while it has focus.

### Resetting the Input Value from a broadcast: Hooks 
* See above, cannot do something like `value={"#{@currentInput}"}` to reset (will fail while focus)

  * So: push an event by the live view, as
```
socket |> ... |> push_event("reset_input_field", %{})
```
  * And define a custom hook for lower-level-JS/HTML-Interoperability:
```<input ... phx-hook="ResetInputOnUpdate" id="<any id>"```
  * define hook as seen in `api.js` and `hooks.js`
```
ResetInputOnUpdate: {
    mounted() {
        this.handleEvent("reset_input_field", message => {
            this.el.value = "";
        });
    },
}
```
> cf. commit d2dd850

### Excursion: Show all colors with some interactivity
* We love interactive frontends, so we want to have a list of all available colors,
  but in ordner not to distract, they should only show their color on mouse hover.
* demonstrate for loop in the HEEX
> See Commit 6fe673c 

### Session Storage: keep ID after reload
* simple hook that does not think much on its own
* "session_load" that pushEvent() something back
* another form of pattern matching e.g.
  ```
    def handle_event("hydrate", nil, socket) do
      IO.inspect(socket, label: "in the nil branch")
      {:noreply, socket}
    end
  
    def handle_event("hydrate", stored_session, socket) do
      IO.inspect(stored_session, label: "stored_session")
      {:noreply, socket}
    end
  ```

  goes in the order from top to bottom until first match  

  ```
  def handle_event("hydrate", token_data, socket) when is_binary(token_data) do
  IO.inspect(token_data, label: "token_data binary")
  {:noreply, socket}
  end

  def handle_event("hydrate", token_data, socket) do
  {:noreply, socket}
  end
  ```
  * Event flow
    * BE > FE: "just give me everything you have"
    * FE > BE: "there you go"
    * BE decides
      * is this nil? -> new session, keep the initial ID
      * matches %{"id" => ...} ? -> take this ID instead
      * something else? is an error, do not assign(initialized: true)

* btw: tried it, but the "session-storer" would not work in the root template
  * which is defined in `lib/elixir_wordgame_web/components/layouts/root.html.heex`
  * but then "hook: unable to push hook event. LiveView not connected -  ..."
    * --> needs to be in the 

### Initialized-State in the Template
* can replace
```
<%= if @initialized, do: 'Your ID: ' <> @clientId, else: 'initializing...' %>
```
* but better would be to have a huge loading screen before everything.
* Let's define a guarding LiveComponent

-> ElixirWordgame.InitializationGuard use Phoenix.LiveComponent and
```
<.live_component module={InitializationGuard} id="..." initialized={@initialized}>
  ...
</.live_component>
```
who then, if initialized, can render
```
~H"""
  <div style="display: contents">
    <%= render_slot(@inner_block) %>
  </div>
"""
```

### Upcoming Next: Storing Points in the GenServer...

### Postponed
* Ecto Integration (Database and Schemas)
* Functional components (simpler than live components, also possible)
* exact differences PubSub / GenServer / LiveView
  * LiveView _is_ a GenServer 
* Identifying a certain client? (I guess it would need to store a ID in its sessionStorage)

## General stuff
Language
* :atoms
* _unused convention is a rule
* function/1 notation -> i.e. like Python, Elixir is dynamically but strongly typed (no automatic type coercion, but a variable doesn't have an innate type)
  * "def" (public) and "defp" (private); but no nested functions
* last line is return value
* "if" also has "unless" (and there is "cond" which is like multi-if)
* destructuring / everything is pattern-matching rather than assignment
  * focus on Immutability
  * i.e. there are no while-loops
* wants various "overwrites" to be grouped together
* = is not assignment, it is pattern matching
    * a = 1 matches -> a will be 1 
  * ^ Pin Operator (match the pattern without evaluate again. ...eh??)
    * ^a = 2 can only match if the pinned (previous) value of a is also 2
> The ^Phoenix.PubSub part uses the pin operator to ensure that the atom :pubsub is matched exactly as it is, without being evaluated. This is important because atoms in Elixir are unique identifiers, and changing the evaluation order could lead to different atoms being matched, which would cause the pattern match to fail.
> In this specific case, the pin operator is used to ensure that the Phoenix.PubSub atom is matched exactly as it appears in the pattern, preventing any potential issues with atom evaluation order. This is a common practice when dealing with atoms in patterns, especially in larger applications or libraries where the risk of unintentionally matching a different atom is higher.

Framework
- usually return tuples {:noreply, socket}, {:ok, ...} or errors
- also used e.g. in file reading etc. -> pattern matching

Infra / Workflow
* no "npm install", rather "mix hex.info <package_name>" -> add manually -> "mix deps.get"
* Live Reloading on by default, but might look into configuration in case of wonders
* mix format
* stacktraces get transported to the frontend, if the server can't just be restarted 
 