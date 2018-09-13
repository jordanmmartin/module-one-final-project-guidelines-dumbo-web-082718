require_relative '../config/environment'
require_relative 'constants'

prompt = TTY::Prompt.new

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
  if user_input = "quit"
    status = end_game
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
  puts "Let's Play!"
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
            if (character_answer_key - guesses).empty?
              puts "YOU WON!"
              #add another hangman pic and add filled blank spaces
              puts "The answer was: #{character}."
              break
            end
      end
    else
      puts HANGMAN_PICS[image_index]
      puts "Sorry, you lost."
      puts "The answer was: #{character}."
      #save data from game into user_game and user tables
      break
    end
  end
end

#Home Screen
end_game = 4
status = 0
while status < end_game
case status
when 0
  puts "Welcome to Marvel Hangman!"

  new_user_answer = prompt.select("Choose One:", %w(New\ User Existing\ User Quit))

  # puts "Are you new user? (Y/N)?"
  # new_user_answer = gets.chomp.downcase
  # while valid_user_input(new_user_answer) == false
  #   puts "Are you new user? (Y/N)?"
  #   new_user_answer = gets.chomp.downcase
  # end
  case new_user_answer
  when "New User"
    puts "Welcome new user!"
    # puts "What is your name?"
    # new_name = gets.chomp.downcase
    new_name = prompt.ask('What is your name?')
    # puts "Hello, #{new_name}! Please type in a user name:"
    # new_username = gets.chomp.downcase
    new_username = prompt.ask("Hello, #{new_name}! Please type in a user name:")
    # new_user = User.create(new_name, new_username)
    #create row in user table
    #set local variable for user_id
    status = 1
  when "Existing User"
    puts "Welcome back! What is your username?"
    username = gets.chomp.downcase
    #find user_id by entering username
    #set local variable for user_id
    status = 1
  when "Quit"
    status = end_game
  end
when 1
  # puts "What would you like to do?"
  # puts "See Stats (Y)"
  # puts "Play new Game (N)"
  # stats_or_game = gets.chomp.downcase
  stats_or_game = prompt.select("What would you like to do?", %w(See\ Stats Play\ New\ Game))
  # while valid_user_input(stats_or_game) == false
  #   puts "What would you like to do?"
  #   puts "See Stats (Y)"
  #   puts "Play new Game (N)"
  #   stats_or_game = gets.chomp.downcase
  # end

  case stats_or_game
  when "See Stats"
    #displaying stats for specific user id
    puts "Games Won: #{}"
    puts "Games Lost #{}"
    puts "Percentage Won: #{}%"
    puts "----------------------------"
    puts "Correct Guesses: #{}"
    puts "Incorrect Guesses: #{}"
    puts "Percentage Correct: #{}%"
    stats_input = prompt.select("What would you like to do?", %w(Play\ New\ Game Change\ Name Delete\ Account))
    case stats_input
    when "Play New Game"
      status = 2
    when "Change Name"
    when "Delete Account"
    end
  when "Play New Game"
    status = 2
    # puts "One moment..."
    # run_game
    # status = 2
  end
when 2
  puts "One moment..."
  run_game
  status = 3
when 3

end
end


# puts "Number of Wrong Guesses: #{num_incorrect}"
# puts "Number of Right Guesses: #{num_correct}"
