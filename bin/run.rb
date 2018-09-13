require_relative '../config/environment'
require_relative 'constants'

require 'pry'

#Helper Methods
def validate(guess, guesses)
  if guess.length == 1
    if ALPHABET.include?(guess)
      if !guesses.include?(guess)
        true
      else
        puts "You already guessed that."
        false
      end
    else
      puts "Invalid entry. Guess has to be a letter"
      false
    end
  else
    puts "Invalid! Guess can only by one character."
    false
  end
end

def valid_user_input(user_input)
  if user_input.length == 1
    if user_input == "y" || user_input == "n"
      true
    else
      puts "Invalid entry. Input has to be Y/N"
      false
    end
  else
    puts "Invalid! Input can only by one character(Y/N)."
    false
  end
end

#method to start new game
def run_game
  #Accessing Marvel Api to get a single character name
  prng = Random.new
  characters_array = []
  offset = prng.rand(1...14) * 100

  @client.characters(limit: 100, offset: offset).each do |character|
    characters_array << character[:name]
  end

  split_characters_array = []
  characters_array.each do |character|
    split_characters_array << character.split(" (")[0]
  end

  character = split_characters_array.uniq.sample
  character_display_key = character.split(//)
  character_display_key_downcase = character.downcase.split(//)
  character_answer_key = character_display_key_downcase.select {|char| ALPHABET.include?(char)}


  character_name_blank_spaces = character_display_key_downcase.map do |char|
    if ALPHABET.include?(char)
      char = "_"
    else
      char
    end
  end


  #New Game running
  guesses = []
  image_index = 0
  num_incorrect = 0
  num_correct = 0
  while (character_answer_key - guesses).any?
    if num_incorrect < 6
      #displaying hangman
      puts HANGMAN_PICS[image_index]
      #displaying blank spaces
      character_name_blank_spaces.each do |char|
        print char
      end
      #display previous guesses
      guesses.uniq.each do |char|
        if char == guesses.uniq.first
          print "\nPrevious Guesses: #{char}"
        elsif char == guesses.uniq[1]
          print ", #{char}, "
        elsif char == guesses.uniq.last
          print "#{char}"
        else
          print "#{char}, "
        end
      end
      puts "\nMake a guess:"
      guess = gets.chomp.downcase
      if validate(guess, guesses)
          if character_answer_key.include?(guess)
            num_correct += 1
            update_index = 0
            update_index_array = []
            character_display_key_downcase.each do |char|
              if char == guess
                update_index_array << update_index
              end
              update_index += 1
            end
            update_index_array.each do |index|
              character_name_blank_spaces[index] = character_display_key[index]
            end
          else
            num_incorrect += 1
            image_index += 1
          end
          guesses << guess
      end
    else
      puts HANGMAN_PICS[image_index]
      puts "Sorry, you lost."
      puts "The answer was: #{character}."
      #save data from game into user_game and user tables
      break
    end
    puts "YOU WON!"
    puts "The answer was: #{character}."
  end
end

#Home Screen
puts "Welcome to Marvel Hangman!"
puts "Are you new user? (Y/N)?"
new_user_answer = gets.chomp.downcase
while valid_user_input(new_user_answer) == false
  puts "Are you new user? (Y/N)?"
  new_user_answer = gets.chomp.downcase
end
case new_user_answer
when "y"
  puts "Welcome new user!"
  puts "What is your name?"
  name = gets.chomp.downcase
  puts "Hello, #{name}! Please type in a user name:"
  username = gets.chomp.downcase
  user = User.new(name, username)
when "n"

else
end



# puts "Number of Wrong Guesses: #{num_incorrect}"
# puts "Number of Right Guesses: #{num_correct}"
