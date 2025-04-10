# frozen_string_literal: true

module Darkfang
  # Represents an item in the game world
  class Item
    attr_reader :id, :name, :description, :weight, :type, :attack, :defense

    def initialize(id, data)
      @id = id
      
      # Extract attributes from the array of hashes
      data.each do |attr|
        attr.each do |key, value|
          case key
          when "name"
            @name = value
          when "description"
            @description = value
          when "weight"
            @weight = value.to_i
          when "type"
            @type = value
          when "attack"
            @attack = value.to_i
          when "defense"
            @defense = value.to_i
          end
        end
      end
      
      # Set defaults for missing attributes
      @weight ||= 1
      @attack ||= 0
      @defense ||= 0
      @type ||= "misc"
    end

    def to_s
      "#{@name} (#{@type})\n#{@description}\nWeight: #{@weight}"
    end
  end
end
