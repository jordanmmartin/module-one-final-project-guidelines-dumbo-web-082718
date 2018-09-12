class CreateUserGames < ActiveRecord::Migration[5.0]
  def change
    create_table :user_games do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :correct_guesses
      t.integer :incorrect_guesses
      t.boolean :user_win
    end
  end
end
