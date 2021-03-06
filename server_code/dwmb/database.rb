require 'rubygems'
require 'data_mapper'
require_relative 'config'

module Dwmb

  puts Config::Database
  DataMapper.setup(:default, Config::Database)

  class Card
    include DataMapper::Resource
    property :id,         Serial
    property :rfid,     String

    belongs_to :user
  end

  class User
    include DataMapper::Resource
    property :id,         Serial
    property :email,      String
    property :username,   String
    property :password,   BCryptHash
    property :code,       String

    has 1, :card
    has n, :sessions
    has n, :events
  end

  class Session
      include DataMapper::Resource
      property :id,   Serial
      property :session_id, String
      belongs_to :user
  end

  class Event
      include DataMapper::Resource
      property :id, Serial
      property :time, DateTime
      property :type, Enum[ :registered, :connected, :disconnected, :alarm, :logged, :restored]
      property :slot, String
      property :snapshot, String
      belongs_to :user
  end

  class Telegram
      include DataMapper::Resource
      property :id, Serial
      property :chatid, String
  end

  DataMapper.finalize

  Card.auto_upgrade!
  User.auto_upgrade!
  Session.auto_upgrade!
  Event.auto_upgrade!
  Telegram.auto_upgrade!
end
