require "stateful/builders/event"

module Stateful #:nodoc:
  module Builders #:nodoc:
    class Event #:nodoc:
      def initialize(event)
        @event = event
      end
      
      def update(&block)
        instance_eval(&block)
      end
      
      def moves(pair)
        raise BadTransition.new(pair) unless Hash === pair && pair.size == 1
        froms, to = pair.keys.first, pair.values.first        
        Array(froms).each { |from| @event.transitions[from] = to }
      end
      
      def stays(*names)
        names.each { |n| moves(n => n) }
      end
    end
  end
end
