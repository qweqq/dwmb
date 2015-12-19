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
                @type = :non
                @slot = :non
            end
        end

        def initialize
            @leaving = nil
            @connecting = nil
            @alarm = Alarm.new
            @current_slots = Array.new(8, nil)
            @timers = Timers::Group.new
            @thread = Thread.new do
                loop { @timers.wait }
            end
            setTimers
        end

        def on_ramp? card_id
            current_slots.each do |user|
                return true if user.card == card_id
            end
            return false
        end

        def stateChanged new_state
            puts names
            current_slots.each_with_index do |user, index|
                if (user and new_state[index] == 0)
                    if index == leaving
                        leaving = :non
                        current_slots[index] = nil
                        return :left
                    else
                        alarm.alarm = true
                        alarm.slot = index
                        current_slots[index] = nil
                        alarm.type = :theft
                        return :theft
                    end
                elsif (not user and new_state[index] == 1)
                     if @connecting
                         current_slots[index] = @connecting
                         @connecting = nil
                         return :connected
                    else
                        return :cable
                    end
                end
            end
            return :ok
        end

        def setTimers
            timer = @timers.after(3){
                alarm.alarm = true
                alarm.type = :device
                alarm.slot = :non
            }
        end
    end
end
