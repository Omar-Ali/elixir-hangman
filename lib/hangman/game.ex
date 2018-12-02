defmodule Hangman.Game do

  alias Hangman.Dictionary

  defstruct(
    letters: [],
    game_state: :initializing,
    turns_left: 7,
    used: MapSet.new()
  )

  def new_game(word) do
    %Hangman.Game{
      letters: word |> String.codepoints
    }
  end
  def new_game do
    new_game(Dictionary.random_word())
  end

  def make_move(game = %{ game_state: state } , _guess) when state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  def make_move(game, guess) do
    accept_move(game, validate_guess(guess), MapSet.member?(game.used, guess) )
    |> return_with_tally()
  end

  def accept_move(game, _not_valid_guess = :not_valid_guess, _) do
    game
  end

  def accept_move(game, _, _already_used = true) do
    Map.put(game, :game_state, :already_used)
  end

  def accept_move(game, guess, _not_alredy_used) do
    Map.put(game, :used, MapSet.put(game.used, guess) )
    |> score_guess(Enum.member?(game.letters, guess) )
  end

  def score_guess(game, _good_guess = true) do
    new_state = MapSet.new(game.letters)
    |> MapSet.subset?(game.used)
    |> win_or_good_guess()
    Map.put(game, :game_state, new_state)
  end

  def score_guess(game = %{ turns_left: 1 }, _bad_guess ) do
    Map.put(game, :game_state, :lost)
  end

  def score_guess(game = %{ turns_left: turns_left }, _bad_guess) do
    %{
      game |
      game_state: :bad_guess,
      turns_left: turns_left - 1
    }
  end

  def validate_guess(guess) do
    is_valid = guess =~ ~r(^[a-z]*$)
    is_valid = is_valid and String.length(guess) == 1
    guess_or_not_valid(guess, is_valid)
  end

  def guess_or_not_valid(guess, true), do: guess
  def guess_or_not_valid(_, _), do: :not_valid_guess

  def win_or_good_guess(true), do: :won
  def win_or_good_guess(_), do: :good_guess

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: game.letters |> reveal_gussed(game.used),
      used: MapSet.to_list game.used
    }
  end

  def reveal_gussed(letters, used) do
    letters
    |> Enum.map(fn letter -> reveal_letter(letter, MapSet.member?(used, letter) ) end )
  end

  def reveal_letter(letter, _guessed = true), do: letter
  def reveal_letter(_letter, _not_guessed), do: "-"

  defp return_with_tally(game), do: { game, tally(game) }
end