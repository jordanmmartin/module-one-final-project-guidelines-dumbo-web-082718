class Game < ActiveRecord::Base
  has_many :usergame
  has_many :user, through: :usergame

end
