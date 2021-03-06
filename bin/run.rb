require_relative '../config/environment'
require_relative 'constants'

prompt = TTY::Prompt.new

require 'pry'

#Helper method to validate user input during the game
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


#method to start new game
def run_game(user_id, user)
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
  game = Game.create
  game_id = game.id
  usergame = UserGame.create(user_id: user_id, game_id: game_id)
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
              puts WIN
              #add another hangman pic and add filled blank spaces
              puts "The answer was: #{character}."
              puts "Number of Wrong Guesses: #{num_incorrect}"
              puts "Number of Right Guesses: #{num_correct}"
              usergame.user_win = true
              user.number_wins += 1
              break
            end
      end
    else
      puts HANGMAN_PICS[image_index]
      puts LOSE
      puts "The answer was: #{character}."
      puts "Number of Wrong Guesses: #{num_incorrect}"
      puts "Number of Right Guesses: #{num_correct}"
      #save data from game into user_game and user tables
      usergame.user_win = false
      user.number_losses += 1
      break
    end
  end
  usergame.correct_guesses = num_correct
  usergame.incorrect_guesses = num_incorrect
  user.total_correct_guesses += num_correct
  user.total_incorrect_guesses += num_incorrect
  usergame.save
  user.save
end



#Home Screen
end_game = 5
status = 0
while status < end_game
case status
when 0
  print "--------------------------------------------------"
  puts WELCOME
  puts "--------------------------------------------------"
  new_user_answer = prompt.select("Choose One:", %w(New\ User Existing\ User Quit))
  case new_user_answer
  when "New User"
    puts "Welcome new user!"
    new_name = prompt.ask('What is your name?').downcase
    new_username = prompt.ask("Hello, #{new_name.capitalize}! Please type in a user name:").downcase
    #double check not exisiting user
      user = User.find_or_create_by(username: new_username, name: new_name)
      if user.number_wins == nil || user.number_losses == nil || user.total_correct_guesses == nil || user.total_incorrect_guesses == nil
        user.number_wins = 0
        user.number_losses = 0
        user.total_correct_guesses = 0
        user.total_incorrect_guesses = 0
        user.save
      end
    user_id = user.id
    stats_or_game = prompt.select("What would you like to do?", %w(Play\ New\ Game See\ Stats Go\ Home))
    status = 1
  when "Existing User"
    username = prompt.ask('What is your username?').downcase
    user = User.find_by(username: username)
    if user == nil
      puts "No user with that user name found."
      status = 0
    else
    user_id = user.id
    stats_or_game = prompt.select("What would you like to do?", %w(Play\ New\ Game See\ Stats Go\ Home))
    status = 1
    end
  when "Quit"
    status = end_game
  end
when 1
  case stats_or_game
  when "See Stats"
    #displaying stats for specific user id
    games_won = user.number_wins
    games_lost = user.number_losses
    # percent_win = games_won / (games_won + games_lost) * 100
    total_correct = user.total_correct_guesses
    total_incorrect = user.total_incorrect_guesses
    # percent_correct = total_correct / (total_correct + total_incorrect) * 100
    name = user.name
    username = user.username
    puts "----------------------------"
    puts "Your Name: #{name}"
    puts "Your Username: #{username}"
    puts "----------------------------"
    puts "Games Won: #{games_won}"
    puts "Games Lost: #{games_lost}"
    # puts "Percentage Won: #{percent_win}%"
    puts "----------------------------"
    puts "Correct Guesses: #{total_correct}"
    puts "Incorrect Guesses: #{total_incorrect}"
    puts "----------------------------"
    # puts "Percentage Correct: #{percent_correct}%"
    stats_input = prompt.select("What would you like to do?", %w(Play\ New\ Game Change\ Name Delete\ Account Go\ Home))
    case stats_input
    when "Play New Game"
      status = 2
    when "Change Name"
      changed_name = prompt.ask('What would you like to change you name to:')
      user.name = changed_name
      user.save
      puts "Your name has been successfully changed."
    when "Delete Account"
      delete_account = prompt.select("Are you sure you want to delete your account?", %w(Yes No))
      case delete_account
      when "Yes"
        user.destroy
        puts "Your account has been successfully delete."
        status = 0
      when "No"
        status 1
      end
    when "Go Home"
      status = 0
    end
  when "Play New Game"
    status = 2
  when "Go Home"
    status = 0
  end
when 2
  puts "One moment..."
  run_game(user_id, user)
  status = 3
when 3
  end_game_input = prompt.select("What would you like to do?", %w(Play\ Again See\ Stats Go\ Home Quit))
  case end_game_input
  when "Play Again"
    status = 2
  when "See Stats"
    status = 1
    stats_or_game = "See Stats"
  when "Go Home"
    status = 0
  when "Quit"
    status = end_game
  end
end
end
