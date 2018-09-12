require 'bundler'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'lib'

@client = Marvel::Client.new

@client.configure do |config|
  config.api_key = 'd087cb77ac0c58b3ce6d6dcff650b3df'
  config.private_key = '629afab444c98038a3af49108ef861c74df21526'
end
