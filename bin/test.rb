require_relative '../config/environment'
require 'pry'
require_relative 'constants'
prompt = TTY::Prompt.new
# alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
# "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
# guesses = ["a", "b", "c"]
# guesses = []
# num_wrong = 0
# num_right = 0
# while (answer - guesses).any?
#   if num_wrong < 6
#     puts "Make a guess:"
#     guess = gets.chomp.downcase
#     if guess.length == 1
#       if alphabet.include?(guess)
#         if !guesses.include?(guess)
#           if answer.include?(guess)
#             num_right += 1
#           else
#             num_wrong += 1
#           end
#         else
#           puts "You already guessed that."
#         end
#       else
#         puts "Invalid entry. Guess has to be a letter"
#       end
#     else
#       puts "Invalid! Guess can only by one character."
#     end
#     guesses << guess
#   else
#     #save data from game into user_game and user tables
#     break
#   end
# end
#
# puts "Answer: #{answer}"
# puts "Guesses: #{guesses}"
# puts "Number of Wrong Guesses: #{num_wrong}"
# puts "Number of Right Guesses: #{num_right}"

prompt.select("Choose One:", %w(New\ User Existing\ User))
