require_relative '../config/environment'
require_relative 'constants'

require 'pry'



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


character_name_blank_spaces = character_answer_key.map do |char|
  if ALPHABET.include?(char)
    char = "_"
  else
    char
  end
end




guesses = []
image_index = 0

def validate(guess, guesses)
  if guess.length == 1
    true
    if ALPHABET.include?(guess)
      true
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



# character_name_blank_spaces.each do |char|
#   print char
# end

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
          #display updated blank spaces
          update_index = character_answer_key.index(guess)
          character_name_blank_spaces[update_index] = character_display_key[update_index]
        else
          num_incorrect += 1
          image_index += 1
          #display same blank spaces
        end
        guesses << guess
        #displaying guesses
        # guesses.uniq.each do |char|
        #   if char == guesses.uniq.first
        #     print "\nPrevious Guesses: #{char}"
        #   elsif char == guesses.uniq[1]
        #     print ", #{char}, "
        #   elsif char == guesses.uniq.last
        #     print "#{char}"
        #   else
        #     print "#{char}, "
        #   end
        # end
    end
  else
    puts HANGMAN_PICS[image_index]
    puts "Sorry, you lost."
    #save data from game into user_game and user tables
    break
  end
end

puts "Answer: #{character_answer_key}"
puts "Guesses: #{guesses}"
puts "Number of Wrong Guesses: #{num_incorrect}"
puts "Number of Right Guesses: #{num_correct}"
