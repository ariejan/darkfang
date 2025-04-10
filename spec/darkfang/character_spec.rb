# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Character do
  before do
    setup_test_directory
    Darkfang.load_config
    Darkfang.init_world
    Darkfang.init_game
  end
  
  after do
    cleanup_test_directory
  end
  
  let(:player) { create_test_player }
  let(:character_data) do
    {
      "id" => SecureRandom.uuid,
      "name" => "TestCharacter",
      "health" => 100,
      "max_health" => 100,
      "inventory" => [],
      "room_id" => "start"
    }
  end
  
  describe "#initialize" do
    it "initializes a character with the given data" do
      character = described_class.new(character_data, player)
      
      expect(character.id).to eq(character_data["id"])
      expect(character.name).to eq(character_data["name"])
      expect(character.health).to eq(character_data["health"])
      expect(character.max_health).to eq(character_data["max_health"])
      expect(character.inventory).to eq([])
      expect(character.room_id).to eq(character_data["room_id"])
      # Player is stored as an instance variable but not exposed via attr_reader
      expect(character.instance_variable_get(:@player)).to eq(player)
    end
  end
  
  describe "#enter_room" do
    it "updates the character's room and room_id" do
      character = described_class.new(character_data, player)
      room = Darkfang.world.rooms["start"]
      
      # Mock methods to avoid errors
      allow(room).to receive(:add_player)
      allow(character).to receive(:save)
      
      character.enter_room(room)
      
      expect(character.room).to eq(room)
      expect(character.room_id).to eq(room.id)
    end
  end
  
  describe "#look" do
    it "returns a description of the current room" do
      character = described_class.new(character_data, player)
      room = Darkfang.world.rooms["start"]
      
      # Set up the room properly
      character.instance_variable_set(:@room, room)
      allow(room).to receive(:to_s).and_return("Room description")
      
      expect(character.look).to eq("Room description")
    end
    
    it "returns an error message if not in a room" do
      character = described_class.new(character_data, player)
      allow(character).to receive(:room).and_return(nil)
      
      expect(character.look).to eq("You are not in a room.")
    end
  end
  
  describe "#to_json" do
    it "returns a JSON representation of the character" do
      character = described_class.new(character_data, player)
      
      json = character.to_json
      data = JSON.parse(json)
      
      expect(data["id"]).to eq(character_data["id"])
      expect(data["name"]).to eq(character_data["name"])
      expect(data["health"]).to eq(character_data["health"])
      expect(data["max_health"]).to eq(character_data["max_health"])
      expect(data["room_id"]).to eq(character_data["room_id"])
      expect(data["inventory"]).to be_an(Array)
    end
  end
  
  describe "#save" do
    it "calls save_character on the game" do
      character = described_class.new(character_data, player)
      
      expect(Darkfang.game).to receive(:save_character).with(character)
      
      character.save
    end
  end
end
