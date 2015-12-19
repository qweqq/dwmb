require 'timers'
require_relative 'config'
require_relative 'database'


module Dwmb
    class Setup
        attr_accessor :current_slots, :alarm, :leaving, :connecting

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
                alarm.alarm = true
                alarm.type = :device
                alarm.slot = :none
            }
        end

        def mark_user_for_leaving(user)
            current_slots.each_with_index do |slot, index|
                current_slots[index] = [user, :leaving] if slot[0] == user
            end
        end

        def on_ramp? rfid
            current_slots.each do |user, state|
                return true if user and user.card.rfid == rfid
            end
            return false
        end

        def state_update new_states
            p "-------NOW---------"
            p new_states
            p current_slots
            p "----------------"

            result = :ok

            current_slots.each_with_index do |slot, index|
                current_slot_user = slot[0]
                current_slot_state = slot[1]
                new_state = new_states[index]

                if (not current_slot_user and new_state == 1)
                    if @connecting
                        current_slots[index] = [current_slot_user, :none]
                        @connecting = nil
                        result = :connected
                    else
                        result = :cable
                    end
                elsif (current_slot_user and new_state == 0)
                    if current_slot_state == :leaving
                        current_slots[index] = [nil, :none]
                        result = :left
                    else
                        current_slots[index] = [current_slot_user, :theft]
                        alarm.alarm = true
                        alarm.slot = index
                        alarm.type = :theft
                        result = :theft
                    end
                end
            end

            p "-------AFTER---------"
            p new_states
            p current_slots
            p "----------------"

            return result
        end
    end
end
