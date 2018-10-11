defmodule Memory.Game do
  # Start a new game 
  def new() do
    good_vals = ["A", "B", "C", "D", "E", "F", "G", "H"]
    actual_good_vals = Enum.shuffle(good_vals ++ good_vals)
    tiles_list_2 = Enum.map(actual_good_vals, fn x -> %{val: x, show: false} end)
    tiles_list_1 = Enum.with_index(tiles_list_2)
    tiles_list = Enum.map(tiles_list_1, fn x -> Map.put(elem(x, 0), :id, elem(x, 1)) end)

    %{
      total_guesses: 0,
      current_guesses: [],
      tiles: tiles_list,
      player: [%{name: "a", is_turn: true, points: 0}, %{name: "b", is_turn: false, points: 0}]
    }
  end

  # Map players to their name and info 
  def new(players) do 

  end

  def is_full(game) do
    false
  end

  def add_player(game, user) do 
  end

  # The client view 
  def client_view(game_state) do
    tiles_list =
      Enum.map(game_state.tiles, fn x ->
        if x.show == true do
          x
        else
          Map.put(x, :val, "HIDDEN")
        end
      end)

    %{
      player1_name: Enum.at(game_state.player, 0)[:name],
      player2_name: Enum.at(game_state.player, 1)[:name],
      player1_points: Enum.at(game_state.player, 0)[:points],
      player2_points: Enum.at(game_state.player, 1)[:points],
      player1_turn: Enum.at(game_state.player, 0)[:is_turn],
      player2_turn: Enum.at(game_state.player, 1)[:is_turn],
      tiles: tiles_list
    }
  end

  # Add a new guess to the list of current guesses, return if there are already 2 gueses in the list
  def add_new_guess(game_state, index, player) do
    if length(game_state.current_guesses) < 2 && check_is_name_and_turn(game_state, player) do
      real_index = elem(Integer.parse(index), 0)

      tiles =
        List.update_at(game_state.tiles, real_index, fn x ->
          %{val: x.val, show: true, id: x.id}
        end)

      current_guesses = game_state.current_guesses ++ [Enum.at(game_state.tiles, real_index).val]
      total_guesses = game_state.total_guesses + 1

      %{
        total_guesses: total_guesses,
        current_guesses: current_guesses,
        tiles: tiles
      }
    else
      game_state
    end
  end

  # Check if the cards in the list of current guesses are equal
  def eval_guesses(game_state) do
    if length(game_state.current_guesses) >= 2 do
      if Enum.at(game_state.current_guesses, 0) != Enum.at(game_state.current_guesses, 1) do
        new_tiles =
          Enum.map(game_state.tiles, fn x ->
            if Enum.member?(game_state.current_guesses, x.val) do
              Map.put(x, :show, false)
            else
              x
            end
          end)

        Map.put(game_state, :tiles, new_tiles)
        |> Map.put(:current_guesses, [])
        |> update_turn
      else
        Map.put(game_state, :current_guesses, [])
        |> update_points
        |> update_turn
      end
    else
      game_state
    end
  end

  # Add a one to the player's points 
  def update_points(game_state) do
    if Enum.at(game_state.player, 0)[:is_turn] do
      points = Enum.at(game_state.player, 0)[:points] + 1
      Map.put(Enum.at(game_state.player, 0), :points, points)
    else
      points = Enum.at(game_state.player, 1)[:points] + 1
      Map.put(Enum.at(game_state.player, 1), :points, points)
    end
  end

  # Switch player's turns
  def update_turn(game_state) do
    player1 =
      Map.put(Enum.at(game_state.player, 0), :is_turn, !Enum.at(game_state.player, 0).is_turn)

    player2 =
      Map.put(Enum.at(game_state.player, 1), :is_turn, !Enum.at(game_state.player, 1).is_turn)

    players = [player1, player2]

    Map.put(game_state, :player, players)
  end

  # Check if game is won
  def is_game_won(game_state) do
    Enum.all?(game_state.tiles, fn x -> !x.show end)
  end

  # Check if the user clicking is one of the players and check if it's their turn
  def check_is_name_and_turn(game_state, player) do
    if player == Enum.at(game_state.player, 0)[:name] do
      if Enum.at(game_state.player, 0)[:is_turn] do
        true
      else
        false
      end
    else
      if player == Enum.at(game_state.player, 1)[:name] do
        if Enum.at(game_state.player, 1)[:is_turn] do
          true
        else
          false
        end
      else
        false
      end
    end
  end

end

