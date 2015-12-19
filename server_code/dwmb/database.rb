require 'rubygems'
require 'data_mapper'
require_relative 'config'

module Dwmb

  DataMapper.setup(:default, Config::Database)

  class Card
    include DataMapper::Resource
    property :id,         Serial
    property :cardid,     String

    belongs_to :user
  end

  class User
    include DataMapper::Resource
    property :id,         Serial
    property :email,       String
    property :username,   String
    property :password,   BCryptHash
    has 1, :card
    has n, :sessions
  end

  class Session
      include DataMapper::Resource
      property :id,   Serial
      property :session_id, String
      belongs_to :user
  end

  DataMapper.finalize

  Card.auto_upgrade!
  User.auto_upgrade!
  Session.auto_upgrade!
end