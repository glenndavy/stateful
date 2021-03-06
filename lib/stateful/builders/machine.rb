require "stateful/builders/event"
require "stateful/event"
require "stateful/state"

module Stateful #:nodoc:
  module Builders #:nodoc:
    class Machine #:nodoc:
      attr_reader :machine
      
      def initialize(machine)
        @machine = machine
      end
      
      def apply(options={}, &block)
        @machine.start = state(options[:start]).name if options[:start]
        instance_eval(&block) if block_given?
        @machine
      end
            
      def on(name, &block)
        event = @machine.events[name] ||= Stateful::Event.new(name)
        Stateful::Builders::Event.new(self, event).apply(&block) if block_given?
        event
      end
      
      def start(name)
        @machine.start = state(name).name
      end
      
      def state(name)
        state = @machine.states[name] ||= Stateful::State.new(name)
        @machine.start = name unless @machine.start
        state
      end
      
      def states(*names)
        names.each { |n| state n }
      end
      
      LISTENERS = { :on => [:firing, :fired], :state => [:entering, :entered, :exiting] }

      LISTENERS.each do |source, kinds|
        kinds.each do |kind|
          class_eval <<-END, __FILE__, __LINE__
            def #{kind}(*names, &block)
              @machine.listeners[#{kind.inspect}] << block if names.empty?
              names.each { |n| #{source}(n).listeners[#{kind.inspect}] << block }
            end
          END
        end
      end      
    end
  end
end
