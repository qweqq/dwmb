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
                loo# p { @timers.wait }
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

        def on_ramp rfid
            current_slots.each_with_index do |slot, index|
                user = slot[0]
                return index if user and user.card.rfid == rfid
            end
            return nil
        end

        def state_update new_states
            @timer.reset
            reset_alarm if alarm.alarm

            # p "|-------NOW---------"
            # p "| ", new_states
            # p "| ", current_slots
            # p "|----------------"

            result = :ok

            current_slots.each_with_index do |slot, index|
                current_slot_user = slot[0]
                current_slot_state = slot[1]
                new_state = new_states[index]

                if (not current_slot_user and new_state == 1)
                    # p "|slot was empty, now it is full"
                    if @connecting
                        # p "|we have a user to connect"
                        @current_slots[index] = [@connecting, :none]
                        @connecting = nil
                        result = :connected
                    else
                        # p "|someone is messing with cables"
                        result = :cable
                    end
                elsif (current_slot_user and new_state == 0)
                    # p "|we had a full slot, now it is empty"
                    if current_slot_state == :leaving
                        # p "|the user has pooped and wants to get his bike!"
                        current_slots[index] = [nil, :none]
                        result = :disconnected
                    else
                        # p "|the user has NOT pooped, and someone is stealing his bike"
                        current_slots[index] = [current_slot_user, :theft]
                        alarm.alarm = true
                        alarm.slot = index
                        alarm.type = :theft
                        result = :theft
                    end
                end
            end

            if result == :ok
                # p "|nothing changed... no poop, no nothing"
            end

            # p "|-------AFTER---------"
            # p "|, ", new_states
            # p "|, ", current_slots
            # p "|----------------"

            return result
        end
    end
end
