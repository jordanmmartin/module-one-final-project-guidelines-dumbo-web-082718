class User < ActiveRecord::Base
  has_many :usergame
  has_many :game, through: :usergame

end
