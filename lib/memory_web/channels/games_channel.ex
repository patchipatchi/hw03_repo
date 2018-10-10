defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.GameServer
  alias Memory.Game

  def join("games:" <> game, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game, game)
      game = Game.add_player(game, socket.assigns[:user])
      view = GameServer.view(game, socket.assigns[:user])
      {:ok, %{"join" => game, "game" => view}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("guess", payload, socket) do 
    view = GameServer.guess(socket.assigns[:game], socket.assigns[:user], payload)
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("restart", _payload, socket) do
    view = GameServer.restart(socket.assigns[:game], socket.assigns[:user])
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("eval", _payload, socket) do
    view = GameServer.eval(socket.assigns[:game], socket.assigns[:user])
    {:reply, {:ok, %{ "game" => view}}, socket}
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
