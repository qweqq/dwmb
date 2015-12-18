require 'sinatra/base'
require 'thin'
require 'json'
require_relative 'database'
require_relative 'setup'
require 'securerandom'

module Dwmb
  class Server < Sinatra::Base
    set :bind, '0.0.0.0'
    set :server, 'thin'
    set :public_folder, '../static'

    def setup
        @@setup ||= Setup.new
    end


    get "/" do
      redirect '/index.html'
    end


    post '/try' do
        slots = JSON.parse(params["data"])["slots"]
        setup.currentSlots.each_with_index do |hole, index|
            setup.currentSlots[index] = slots[index]
            puts "old: #{hole} new: #{slots[index]}"
        end
        return {status:"ok", message:"gsgs gs"}.to_json
    end

    post '/register' do
      user = JSON.parse(params["data"])["slots"]
      card = Card.new(cardid:"42")
      return {status:"error", message:'Username taken'}.to_json if User.first(username:user["username"])
      return {status:"error", message:'Email registered'}.to_json if User.first(email:user["email"])
      u = User.new(username: user["username"],
           email: user["email"],
           password: user["password"],
           card: card)
      u.save
      {status:"ok", message:""}.to_json
    end

    post '/login' do
      login_info = JSON.parse(params["data"])
      user = User.first(username:login_info["username"])
      return {status:"error", message:"Unknown user"}.to_json unless user
      if user["password"] != login_info["password"]
        return {status:"error", message:"Wrong password"}.to_json
      end

      session_id = SecureRandom.base64(32)
      Session.create(session_id:session_id, user:user)
      {status:"ok", session_id:session_id}.to_json
    end

    post '/secret' do
      session_id = JSON.parse(params["data"])["session_id"]
      session = Session.first(session_id:session_id)
      if session
        return {status:"ok", messgae:""}.to_json
      else
        return {status:"error", messgae:"Log in, you fuck"}.to_json
      end
    end
  end
end
