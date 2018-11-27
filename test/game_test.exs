defmodule GameTest do
  use ExUnit.Case
  alias Hangman.Game
  
  test "new_game returns stucture" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
    assert valid_string?(game.letters)
  end

  def is_char?(c) do
    l = String.to_charlist c
    (l >= 'a' && l <= 'z') || (l >= 'A' && l <= 'Z')
  end

  def valid_string?([h | []]), do: is_char?(h)

  def valid_string?([h|t]), do: is_char?(h) and valid_string?(t)

  test "game doesn't change when in case of :won or :lost" do
    for state <- [:won, :lost] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert { ^game, _tally } = Game.make_move(game, "x")
    end
  end

  test "first occurence of the letter doesn't return already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurence of the letter returns already used" do
    game = Game.new_game()
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state != :already_used
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "test a good guess" do
    game = Game.new_game("hamada")
    { game, _tally } = Game.make_move(game, "h")
    assert game.game_state == :good_guess
  end

  test "test a win" do
    game = Game.new_game("hamada")
    { game, _tally } = Game.make_move(game, "h")
    assert game.game_state == :good_guess

    { game, _tally } = Game.make_move(game, "a")
    assert game.game_state == :good_guess

    { game, _tally } = Game.make_move(game, "m")
    assert game.game_state == :good_guess

    { game, _tally } = Game.make_move(game, "d")
    assert game.game_state == :won
  end

  test "a bad guess is recognized" do
    game = Game.new_game("hamada")
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "a game is lost" do
    game = Game.new_game("hamada")
    { game, _tally } = Game.make_move(game, "x")
    assert game.game_state == :bad_guess

    { game, _tally } = Game.make_move(game, "y")
    assert game.game_state == :bad_guess

    { game, _tally } = Game.make_move(game, "z")
    assert game.game_state == :bad_guess

    { game, _tally } = Game.make_move(game, "b")
    assert game.game_state == :bad_guess

    { game, _tally } = Game.make_move(game, "c")
    assert game.game_state == :bad_guess

    { game, _tally } = Game.make_move(game, "w")
    assert game.game_state == :bad_guess

    { game, _tally } = Game.make_move(game, "v")
    assert game.game_state == :lost
  end

  test "not valid guess returns unchanged game" do
    game = Game.new_game()
    assert { ^game, _tally } = Game.make_move(game, "1")
    assert { ^game, _tally } = Game.make_move(game, "sd")
  end
    
end
  