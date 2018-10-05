defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Memory.BackupAgent.get(name) || Memory.Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      Memory.BackupAgent.put(name, game)
      {:ok, %{"join" => name, "game" => Memory.Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("guess", payload, socket) do
    name = socket.assigns[:name]
    game = Memory.Game.add_new_guess(socket.assigns[:game], payload)
    socket = assign(socket, :game, game)
    Memory.BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Memory.Game.client_view(game)}}, socket}
  end

  def handle_in("restart", _payload, socket) do
    name = socket.assigns[:name]
    game = Memory.Game.new()
    socket = assign(socket, :game, game)
    Memory.BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Memory.Game.client_view(game)}}, socket}
  end

  def handle_in("eval", _payload, socket) do
    name = socket.assigns[:name]
    game = Memory.Game.eval_guesses(socket.assigns[:game])
    socket = assign(socket, :game, game)
    Memory.BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Memory.Game.client_view(game)}}, socket}
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
