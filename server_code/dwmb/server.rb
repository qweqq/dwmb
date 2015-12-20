require 'sinatra/base'
require 'thin'
require 'json'
require_relative 'database'
require_relative 'setup'
require 'securerandom'
#require 'pony'

module Dwmb
  class Server < Sinatra::Base
    set :bind, '0.0.0.0'
    set :server, 'thin'
    set :public_folder, Config::Static

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

        setup.current_slots = Array.new(8, [nil, :none])
        setup.connecting = nil

        return "ok"
    end

    post '/disarm' do
        setup.reset_alarm
    end

    post '/dump' do
        p User.all
        p Session.all
        p Card.all
        return "ok"
    end

#------------------------------FRONTEND----------------------------
    #data = {code:....}
    post '/check_code' do
        input = JSON.parse(params["data"])
        user = User.first(code:input["code"])
        return {status:"ok"}.to_json if user
        return {status:"error"}.to_json
    end
    #return-{status:....}


    #data = {username:..., email:...., password:..., code:....}
    post '/register' do
      input = JSON.parse(params["data"])
      user = User.first(code:input["code"])
      return {status:"error", message: "Wrong code"}.to_json unless user

      return {status:"error", message:'Username taken'}.to_json if User.first(username:input["username"])
      return {status:"error", message:'Email registered'}.to_json if User.first(email:input["email"])

      user.username = input["username"]
      user.password = input["password"]
      user.email = input["email"]
      user.code = ""
      user.save!
      Event.create(user: user, slot:"", type: :registered, time:Time.now.utc)
      {status:"ok", message:"registered"}.to_json
    end
    #return - {status:..., message:...}

    #data = {username:..., password:....}
    post '/login' do
      login_info = JSON.parse(params["data"])
      user = User.first(username:login_info["username"])
      return {status:"error", message:"Unknown user"}.to_json unless user
      if user["password"] != login_info["password"]
        return {status:"error", message:"Wrong password"}.to_json
      end

      Event.create(user: user, slot:"", type: :logged, time:Time.now.utc)
      session_id = SecureRandom.base64(32)
      Session.create(session_id:session_id, user:user)
      {status:"ok", session_id:session_id}.to_json
    end
    #return- {status:...., session_id:.....}

	get '/status' do
        setup.timer.reset
		slots = setup.serialise_slots(empty="off", taken="on", error="error")
		{status: "ok", slots: slots}.to_json
	end

    #-----------------------------!!!!!!!!!!!!!!!!!!!!!!!!------------------------
    #data = {[username:....], [date:[date_start, date_end]], [slot:...], [type...]}
    post '/search' do
        input = JSON.parse(params["data"])
        search_input = {}
        if input.has_key?("username")
            user = User.first(username:input["username"])
            if user
                search_input[:user] = user
            else
                return {status: "ok", result:[]}.to_json
            end
        end

        search_input[:slot] = input["slot"] if input.has_key?("slot")
        search_input[:type] = input["type"] if input.has_key?("type")

        if search_input.has_key?("date")
            search_input[:date] = search_input["date"][0]..search_input["date"][1]
        end

        search_result = setup.search_database search_input
        return {status:"ok", result:search_result }.to_json
    end
    #return={status:...result:[{"slot":..., "username":..., "type":...,"time":...}.....{}]}

    #data = {session_id:...}
    post '/user_info' do
        session_id = JSON.parse(params["data"])["session_id"]
        session = Session.first(session_id:session_id)
        return{status:"not logged"}.to_json unless session
        user = session.user
        rfid = user.card.rfid
        user_index = on_ramp rfid
        if user_index
            search_input = {}
            search_input[:user] = user
            search_input[:slot] = user_index
            search_input[:type] = :connected
            search_output = Events.last **search_input
            time = search_output.time
            return{status:"ok", slot:user_index.to_s, time:time}.to_json
        else
            return {status:"not checked"}.to_json
        end
    end

    #***********************DEVICE**********************************************

    #data = {rfid:....}
    post '/poop' do
        rfid = JSON.parse(params["data"])["rfid"]
        card = Card.first(rfid:rfid)
        user = if card then card.user else nil end
        code = ""
        if user
            user_on_ramp = setup.on_ramp(rfid)
            if user_on_ramp
                if setup.current_slots[user_on_ramp][1] == :theft
                    setup.current_slots[user_on_ramp] = [nil, :none]
                    setup.reset_alarm
                    setup.mark_user_for_leaving(user)
                    Event.create(user: user, slot: user_on_ramp.to_s, type: :restored, time:Time.now.utc)
                    return {status: "ok", message: "disconnected"}.to_json
                else
                    setup.mark_user_for_leaving(user)
                    return {status: "ok", message: "disconnecting"}.to_json
                end
            else
                if user.username == "Unknown"
                    code = sprintf '%05d', SecureRandom.random_number(99999)
                    user.code = code
                    user.save!
                end
                setup.connecting = user
                return {status: "ok", message: "connecting", code:code}.to_json
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
    #return = {status:..., message:..., [code:....]}

    #data = {state:...., key:..., snapshot:....}
    post '/alive' do
        data = JSON.parse(params["data"])
        new_states = data["slots"]
        key = data["key"]
        snapshot = data["snapshot"] if data["snapshot"]

        response = {
            status: "ok",
            message: "ok",
            slots: []
        }

        if key != Config::Key
            response[:status] = "error"
            response[:message] = "wrong key"
        else
            message = setup.state_update(new_states, snapshot)
            response[:status] = if message == :theft then 'error' else 'ok' end
            response[:message] = message.to_s
        end
        response[:slots] = setup.serialise_slots
        return response.to_json
    end
    #return-{status:...., message:...., slots:...}
    #message: ["connected", "theft", "disconnected", "cable", "ok"]
  end
end
