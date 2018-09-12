require_relative '../config/environment'

require 'pry'

prng = Random.new
characters_array = []
offset = prng.rand(1...14) * 100

# while offset < 1000
@client.characters(limit: 100, offset: offset).each do |character|
  characters_array << character[:name]
end


split_characters_array = []
characters_array.each do |character|
  split_characters_array << character.split(" (")[0]
end

character = split_characters_array.uniq.sample
character_anser_key = character.split(//)







#   offset += 100
# end

# puts characters_array.count
# binding.pry
