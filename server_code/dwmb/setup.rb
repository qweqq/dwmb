require "timers"

module Dwmb
    class Setup
        attr_accessor :currentSlots

        def initialize
            @currentSlots = Array.new(8, 0)
            @timers = Timers::Group.new
            @thread = Thread.new do
                loop { @timers.wait }
            end
            setTimers
        end

        def setTimers
            timer = @timers.every(3) do
                @currentSlots[0] += 1
                puts @currentSlots
            end
        end
    end
end
