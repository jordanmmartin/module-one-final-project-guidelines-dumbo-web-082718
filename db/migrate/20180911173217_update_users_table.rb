class UpdateUsersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :number_wins, :integer
    add_column :users, :number_losses, :integer
    add_column :users, :total_correct_guesses, :integer
    add_column :users, :total_incorrect_guesses, :integer
  end
end
