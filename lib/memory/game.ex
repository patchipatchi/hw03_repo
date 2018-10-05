defmodule Memory.Game do
  def new() do
    good_vals = ["A", "B", "C", "D", "E", "F", "G", "H"]
    actual_good_vals = Enum.shuffle(good_vals ++ good_vals)
    tiles_list_2 = Enum.map(actual_good_vals, fn x -> %{val: x, show: false} end)
    tiles_list_1 = Enum.with_index(tiles_list_2)
    tiles_list = Enum.map(tiles_list_1, fn x -> Map.put(elem(x, 0), :id, elem(x,1)) end)

    %{
      total_guesses: 0,
      current_guesses: [],
      tiles: tiles_list
    }
  end

  def eval_guesses(game_state) do
    if length(game_state.current_guesses) >= 2 do
      if Enum.at(game_state.current_guesses, 0) != Enum.at(game_state.current_guesses, 1) do
        new_tiles = Enum.map(game_state.tiles, fn x ->
              if Enum.member?(game_state.current_guesses, x.val) do
                Map.put(x, :show, false)
              else
                x
              end
        end)
        Map.put(game_state, :tiles, new_tiles)
        |> Map.put(:current_guesses, [])
      else
        Map.put(game_state, :current_guesses, [])
      end
    else
      game_state
    end
  end

  def is_game_won(game_state) do
    Enum.all?(game_state.tiles, fn x -> !x.show end)
  end

  def add_new_guess(game_state, index) do
    if length(game_state.current_guesses) < 2 do
      real_index = elem(Integer.parse(index), 0)
      tiles = List.update_at(game_state.tiles, real_index, fn x -> %{val: x.val, show: true, id: x.id} end)
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

  def client_view(game_state) do
    tiles_list = Enum.map(game_state.tiles, fn x ->
        if x.show == true do
          x
        else
          Map.put(x, :val, "HIDDEN")
        end
      end)
    %{
      total_guesses: game_state.total_guesses,
      tiles: tiles_list
    }
  end
end
