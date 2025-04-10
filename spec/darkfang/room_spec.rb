# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Room do
  let(:room_id) { "test_room" }
  let(:room_data) do
    {
      "name" => "Test Room",
      "description" => "A test room for RSpec",
      "exits" => {
        "north" => "other_room"
      },
      "automation" => [
        {
          "type" => "cron",
          "cron" => "* * * * *",
          "command" => "echo 'Test automation'"
        }
      ]
    }
  end
  
  subject { described_class.new(room_id, room_data) }
  
  describe "#initialize" do
    it "initializes a room with the given data" do
      expect(subject.id).to eq(room_id)
      expect(subject.name).to eq(room_data["name"])
      expect(subject.description).to eq(room_data["description"])
      expect(subject.exits).to eq(room_data["exits"])
      expect(subject.items).to be_empty
      expect(subject.players).to be_empty
      expect(subject.automation).to be_an(Array)
      expect(subject.automation.first).to be_a(Darkfang::CronAutomation)
    end
  end
  
  describe "#add_player" do
    let(:player) { instance_double("Darkfang::Player", name: "TestPlayer") }
    
    it "adds a player to the room" do
      expect(subject.players).to be_empty
      
      # Mock broadcast to avoid errors
      allow(subject).to receive(:broadcast)
      
      subject.add_player(player)
      
      expect(subject.players).to include(player)
    end
  end
  
  describe "#remove_player" do
    let(:player) { instance_double("Darkfang::Player", name: "TestPlayer") }
    
    it "removes a player from the room" do
      # Mock broadcast to avoid errors
      allow(subject).to receive(:broadcast)
      
      subject.add_player(player)
      expect(subject.players).to include(player)
      
      subject.remove_player(player)
      
      expect(subject.players).not_to include(player)
    end
  end
  
  describe "#add_item" do
    let(:item) { instance_double("Darkfang::Item", name: "TestItem") }
    
    it "adds an item to the room" do
      # Mock broadcast to avoid errors
      allow(subject).to receive(:broadcast)
      
      subject.add_item(item)
      
      expect(subject.items).to include(item)
    end
  end
  
  describe "#remove_item" do
    let(:item) { instance_double("Darkfang::Item", name: "TestItem") }
    
    it "removes an item from the room" do
      # Mock broadcast to avoid errors
      allow(subject).to receive(:broadcast)
      
      # Add the item first
      subject.add_item(item)
      expect(subject.items).to include(item)
      
      subject.remove_item(item)
      
      expect(subject.items).not_to include(item)
    end
  end
  
  describe "#find_item" do
    let(:item) { instance_double("Darkfang::Item", name: "TestItem") }
    
    it "finds an item by name" do
      # Add the item first
      subject.items << item
      allow(item).to receive(:name).and_return("TestItem")
      
      found_item = subject.find_item("testitem")
      
      expect(found_item).to eq(item)
    end
    
    it "returns nil if the item is not found" do
      found_item = subject.find_item("nonexistent_item")
      
      expect(found_item).to be_nil
    end
  end
  
  describe "#to_s" do
    it "returns a string representation of the room" do
      # Add some test items and players
      item = instance_double("Darkfang::Item", name: "TestItem", to_s: "TestItem (weapon)")
      player = instance_double("Darkfang::Player", name: "TestPlayer")
      
      # Mock broadcast to avoid errors
      allow(subject).to receive(:broadcast)
      
      # Add item and player to the room
      subject.items << item
      subject.add_player(player)
      
      result = subject.to_s
      
      expect(result).to include(room_data["name"])
      expect(result).to include(room_data["description"])
      expect(result).to include("Exits:")
      expect(result).to include("north")
    end
  end
end
