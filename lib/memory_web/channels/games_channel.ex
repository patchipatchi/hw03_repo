defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.BackupAgent
  alias Memory.Game

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      Game.add_player(game, socket.assigns[:user])
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      BackupAgent.put(name, game)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("guess", %{"id" => id, "user" => user_id}, socket) do 
    name = socket.assigns[:name]
    game = Game.add_new_guess(socket.assigns[:game], id, user_id)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("restart", _payload, socket) do
    name = socket.assigns[:name]
    game = Game.restart(socket.assigns[:game])
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("eval", _payload, socket) do
    name = socket.assigns[:name]
    game = Game.eval_guesses(socket.assigns[:game])
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
