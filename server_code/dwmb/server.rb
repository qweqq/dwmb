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

    post '/drop' do
        User.all.destroy
        Session.all.destroy
        Card.all.destroy

        adapter = DataMapper.repository(:default).adapter
        adapter.execute("DELETE FROM dwmb_cards WHERE 1")
        adapter.execute("DELETE FROM dwmb_users WHERE 1")
        adapter.execute("DELETE FROM dwmb_sessions WHERE 1")

        return "ok"
    end

    post '/dump' do
        p User.all
        p Session.all
        p Card.all
        return "ok"
    end

    #data = {username: hsdfsd, email: dskj, password: dffdf, card: 1234}
    post '/register' do
      input = JSON.parse(params["data"])
      user = User.first(code:input["code"])

      puts "register: user: ", user

      return {status:"error", message:'Username taken'}.to_json if User.first(username:input["username"])
      return {status:"error", message:'Email registered'}.to_json if User.first(email:input["email"])

      user.username = input["username"]
      user.password = input["password"]
      user.email = input["email"]
      user.code = ""
      user.save!

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

    #json: data = {rfid = xxxxxx}
    post '/poop' do
        rfid = JSON.parse(params["data"])["rfid"]

        card = Card.first(rfid:rfid)
        user = if card then card.user else nil end

        if user
            if setup.on_ramp? rfid
                setup.mark_user_for_leaving(user)
                return {status: "ok", message: "disconnecting"}.to_json
            else
                setup.connecting = user
                return {status: "ok", message: "connecting"}.to_json
            end
        else
            code = sprintf '%05d', SecureRandom.random_number(99999)
            user = User.new
            user.username = "Unknown"
            card = Card.create(rfid:rfid)
            user.card = card
            user.code = code
            user.save!

            setup.connecting = user
            return {status: "ok", message: "connecting", code: code}.to_json
        end
    end
    #message: ["bikedetach", "bikeattach"]

    #json: data = {state = 8*[_], key = "xxxxx"}
    post '/alive' do
        response = JSON.parse(params["data"])
        new_states = response["slots"]
        key = response["key"]

        return {status:"error", message: "wrong key"}.to_json if key != Config::Key

        message = setup.state_update(new_states)

        return {status:"error", message: "theft"}.to_json if message == :theft

        return {status:"ok", message: message.to_s}.to_json
    end
    #message: ["connected", "theft", "left", "cable", "ok"]

  end
end
