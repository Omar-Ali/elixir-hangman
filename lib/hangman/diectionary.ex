defmodule Hangman.Dictionary do

    def random_word() do
        words_list |> Enum.random
    end
    
    def words_list() do
        ["omar", "noha", "yomna", "mohamed", "abdulrahman", "abdullah", "esraa", "aly", "eman", "enayat", "ahmed", "youssef"]
    end
end