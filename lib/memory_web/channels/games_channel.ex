defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.BackupAgent
  alias Memory.Game

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
 #    game = Game.add_player(game, socket.assigns[:user])
      socket = socket
      |> assign(:name, name)
      BackupAgent.put(name, game)
      send(self, {:after_join, game})
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, game}, socket) do
    # Broadcast a refresh message to update the game state
    broadcast! socket, "update_view", Game.client_view(game)
    {:noreply, socket}
  end

  def handle_in("add_player", %{"pname" => user_id}, socket) do
    name = socket.assigns[:name]
    game = Game.add_player(BackupAgent.get(name), user_id)
    socket = assign(socket, :name, name)
    BackupAgent.put(name, game)
    broadcast! socket, "update_view", Game.client_view(game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("guess", %{"id" => id, "user" => user_id}, socket) do 
    name = socket.assigns[:name]
    game = Game.add_new_guess(BackupAgent.get(name), id, user_id)
    socket = assign(socket, :name, name)
    BackupAgent.put(name, game)
    broadcast! socket, "update_view", Game.client_view(game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("restart", _payload, socket) do
    name = socket.assigns[:name]
    game = Game.new()
    socket = assign(socket, :name, name)
    broadcast! socket, "update_view", Game.client_view(game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("eval", _payload, socket) do
    name = socket.assigns[:name]
    game = Game.eval_guesses(BackupAgent.get(name))
    socket = assign(socket, :game, game)
    broadcast! socket, "update_view", Game.client_view(game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("update_view", payload, socket) do
    push socket, "update_view", payload
    {:noreply, socket}
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
