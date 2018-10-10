defmodule Memory.GameServer do
    use GenServer

    alias Memory.Game

    ## Client Interface
    def start_link(_args) do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def view(game, user) do
        GenServer.call(__MODULE__, {:view, game, user})
    end

    def guess(game, user, card) do
        GenServer.call(__MODULE__, {:guess, game, user, card})
    end

    def restart(game, user) do
        GenServer.call(__MODULE__, {:view, game, user})
    end

    def eval(game, user) do
        GenServer.call(__MODULE__, {:view, game, user})
    end

    ## Implementations
    def init(state) do
        {:ok, state}
    end
    
    def handle_call({:view, game, user}, _from, state) do
        gg = Map.get(state, game, Game.new)
        {:reply, Game.client_view(gg, user), Map.put(state, game, gg)}
    end   
    
    # Handle a guess
    def handle_call({:guess, game, user, card}, _from, state) do
        gg = Map.get(state, game, Game.new)
        |> Game.add_new_guess(card, user)
        vv = Game.client_view(gg, user)
        {:reply, vv, Map.put(state, game, gg)}
    end

    # Handle restart
    def handle_call({:restart, game, user}, _from, state) do
        gg = Map.get(state, game, Game.new)
        |> Game.new
        vv = Game.client_view(gg, user)            
        {:reply, vv, Map.put(state, game, gg)}
    end

    # Handle eval
    def handle_call({:eval, game, user}, _from, state) do
        gg = Map.get(state, game, Game.new)
        |> Game.eval_guesses
        vv = Game.client_view(gg, user)
        {:reply, vv, Map.put(state, game, gg)}
    end

end