# frozen_string_literal: true

module Darkfang
  module Commands
    # Base class for all commands
    class Base
      attr_reader :name, :description, :args

      def initialize(name, description, args = [])
        @name = name
        @description = description
        @args = args
      end

      def execute(player, args)
        raise NotImplementedError, "Subclasses must implement execute"
      end

      def self.register(game)
        raise NotImplementedError, "Subclasses must implement register"
      end
    end
  end
end
