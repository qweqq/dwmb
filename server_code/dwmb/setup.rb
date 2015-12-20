require 'timers'
require_relative 'config'
require_relative 'database'
require 'base64'
require 'pony'

module Dwmb
    class Setup
        attr_accessor :current_slots, :alarm, :leaving, :connecting, :timer

        class Alarm
            attr_accessor :alarm, :type, :slot
            def initialize
                @alarm = false
                @type = :none
                @slot = :none
            end
        end

        def initialize
            @alarm = Alarm.new
            @current_slots = Array.new(8, [nil, :none])
            @connecting = nil
            @timers = Timers::Group.new
            @thread = Thread.new do
                loop { @timers.wait }
            end
            setTimers
        end

        def setTimers
            @timer = @timers.after(3){
                puts "ALARM"
                alarm.alarm = true
                alarm.type = :device
                alarm.slot = :none
            }
        end

        def serialise_slots(empty=0, taken=1, error=2)
            serialised_slots = []
            current_slots.each_with_index do |slot, index|
                user = slot[0]
                state = slot[1]
                if user
                    serialised_slots[index] = if state == :theft then error else taken end
                else
                    serialised_slots[index] = empty
                end
            end
            return serialised_slots
        end

        def reset_alarm
            if alarm.alarm
                alarm = Alarm.new
            end
        end

        def mark_user_for_leaving(user)
            current_slots.each_with_index do |slot, index|
                current_slots[index] = [user, :leaving] if slot[0] == user
            end
        end

        def find_user_by(username)
            return User.first(username:username) if username != "Unknown"
            nil
        end

        def search_database(input)
            search_result = Event.all **input
            return processed(search_result)
        end

        def processed(search_result)
            processed_results = []
            search_result.each do |event|
                processed_event = {}
                processed_event["type"] = event.type
                processed_event["time"] = event.time
                processed_event["slot"] = event.slot
                processed_event["username"] = event.user.username
                processed_results << processed_event
            end
            return processed_results
        end

        def on_ramp rfid
            current_slots.each_with_index do |slot, index|
                user = slot[0]
                return index if user and user.card.rfid == rfid
            end
            return nil
        end

        def save_snapshot(name, snapshot="")
            content = snapshot
            decode_base64_content = Base64.decode64(content)
            File.open(File.join(Config::Snapshot_folder, name + ".jpg"), "wb") do |f|
              f.write(decode_base64_content)
            end
        end

        def send_mail (email, name)
            snapshot_name = File.join(Config::Snapshot_folder, name)

            Pony.mail({
    			:to => email,
    			:subject => "DWMB: Alarm!",
    			:body => "Your bike is stolen!",
                :attachments => {"snapshot.jpg" => File.read(snapshot_name)},
    			:via => :smtp,
    			:via_options => Config::Mail_options
    		})
        end

        def state_update(new_states, snapshot=nil)
            @timer.reset
            reset_alarm if alarm.alarm
            result = :ok

            current_slots.each_with_index do |slot, index|
                current_slot_user = slot[0]
                current_slot_state = slot[1]
                new_state = new_states[index]

                if (not current_slot_user and new_state == 1)
                    if @connecting
                        @current_slots[index] = [@connecting, :none]
                        time = Time.now.utc
                        save_snapshot(time.to_i.to_s, snapshot) if snapshot
                        filename = time.to_i.to_s + ".jpg"
                        Event.create(user: @connecting, slot:index.to_s, type: :connected, time:time, snapshot: filename)
                        @connecting = nil
                        result = :connected
                    end
                elsif (current_slot_user and new_state == 0)
                    if current_slot_state == :leaving
                        current_slots[index] = [nil, :none]
                        time = Time.now.utc
                        save_snapshot(time.to_i.to_s, snapshot) if snapshot
                        filename = time.to_i.to_s + ".jpg"
                        Event.create(user: current_slot_user, slot:index.to_s, type: :disconnected, time:time, snapshot: filename)
                        result = :disconnected
                    else
                        if current_slots[index][1] != :theft
                            current_slots[index] = [current_slot_user, :theft]
                            alarm.alarm = true
                            alarm.slot = index
                            alarm.type = :theft
                            time = Time.now.utc
                            save_snapshot(time.to_i.to_s, snapshot) if snapshot
                                filename = time.to_i.to_s + ".jpg"
                            send_mail(current_slot_user.email, filename) if current_slot_user.email
                            Event.create(user: current_slot_user, slot:index.to_s, type: :alarm, time:time, snapshot: filename)
                        end
                        result = :theft
                    end
                end
            end
            return result
        end
    end
end
