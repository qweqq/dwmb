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

    post '/register' do
      user = JSON.parse(params["data"])
      card = Card.create(cardid:"42")
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
        return {status:"ok", message:""}.to_json
      else
        return {status:"error", message:"Log in, you fuck"}.to_json
      end
    end

    #***********************DEVICE**********************************************

    #json: data = {card_id = xxxxxx}
    post '/poop' do
        card_id = JSON.parse(params["data"])["card_id"]

        card_by_id = Card.first(cardid:card_id)
        user = nil
        user = card_by_id.user if (card_by_id)

        if user
            if setup.on_ramp? card_id
                setup.leaving = user
                return {status: "ok", messgae: "bikedetach"}.to_json
            else
                setup.connecting = user
                return {status: "ok", message: "bikeattach"}.to_json
            end
        else
            code = sprintf '%05d', SecureRandom.random_number(99999)
            user = User.new
            user.username = "Unknown"
            card = Card.create(cardid:card_id)
            user.card = card
            user.code = code
            user.save
            return {status: "ok", message: "bikeattach", code: code}.to_json
        end
    end
    #message: ["bikedetach", "bikeattach"]

    #json: data = {state = 8*[_], key = "xxxxx"}
    post '/alive' do
        response = JSON.parse(params["data"])
        new_state = response["state"]
        key = response["key"]
        return {status:"error", message:"wrong key"}.to_json if key != Config::Key
        message = setup.stateChanged new_state
        return {status:"ok", message:message.to_s}.to_json
    end
    #message: ["connected", "theft", "left", "cable", "ok"]

  end
end
