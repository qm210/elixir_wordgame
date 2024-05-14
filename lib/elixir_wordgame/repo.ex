defmodule ElixirWordgame.Repo do
  use Ecto.Repo,
    otp_app: :elixir_wordgame,
    adapter: Ecto.Adapters.SQLite3
end
