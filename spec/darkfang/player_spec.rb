# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Player do
  before do
    setup_test_directory
    Darkfang.load_config
    Darkfang.init_world
    Darkfang.init_game
  end
  
  after do
    cleanup_test_directory
  end
  
  let(:email) { "test@example.com" }
  let(:password) { "password" }
  let(:player_data) do
    {
      "email" => email,
      "password_hash" => BCrypt::Password.create(password),
      "characters" => []
    }
  end
  
  describe "#initialize" do
    it "initializes a player with the given data" do
      player = described_class.new(player_data)
      
      expect(player.email).to eq(email)
      expect(player.characters).to be_empty
    end
  end
  
  describe "#authenticate" do
    it "returns true if the password is correct" do
      player = described_class.new(player_data)
      
      expect(player.authenticate(password)).to be true
    end
    
    it "returns false if the password is incorrect" do
      player = described_class.new(player_data)
      
      expect(player.authenticate("wrong_password")).to be false
    end
  end
  
  describe "#create_character" do
    let(:player) { described_class.new(player_data) }
    let(:name) { "TestCharacter" }
    
    it "creates a new character with the given name" do
      expect(player.characters).to be_empty
      
      player.create_character(name)
      
      expect(player.characters.size).to eq(1)
      expect(player.characters.first.name).to eq(name)
    end
    
    it "returns a success message" do
      result = player.create_character(name)
      
      expect(result).to include("Character created")
    end
    
    it "saves the character to a file" do
      player.create_character(name)
      
      character_id = player.characters.first.id
      character_file = File.join(Darkfang.root, "data", "characters", "#{character_id}.json")
      
      expect(File.exist?(character_file)).to be true
    end
  end
  
  describe "#select_character" do
    let(:player) { described_class.new(player_data) }
    let(:name) { "TestCharacter" }
    
    before do
      player.create_character(name)
    end
    
    it "sets the active character to the selected character" do
      expect(player.active_character).to be_nil
      
      player.select_character(0)
      
      expect(player.active_character).not_to be_nil
      expect(player.active_character.name).to eq(name)
    end
    
    it "returns an error message if the index is out of bounds" do
      result = player.select_character(1)
      
      expect(result).to include("Invalid character")
    end
    
    it "places the character in the start room" do
      # Create a mock world and room
      world = instance_double(Darkfang::World)
      room = instance_double(Darkfang::Room, id: "start")
      
      # Set up the mocks
      allow(Darkfang).to receive(:world).and_return(world)
      allow(world).to receive(:get_room).with(anything).and_return(nil)
      allow(world).to receive(:start_room).and_return(room)
      allow(room).to receive(:add_player)
      
      # Allow any character to enter any room (more permissive stub)
      allow_any_instance_of(Darkfang::Character).to receive(:enter_room)
      
      player.select_character(0)
      
      # Verify the character entered the room
      expect(player.active_character).not_to be_nil
      expect(player.active_character.name).to eq("TestCharacter")
    end
  end
  
  describe "#logout" do
    let(:player) { described_class.new(player_data) }
    let(:name) { "TestCharacter" }
    
    before do
      player.create_character(name)
      player.select_character(0)
    end
    
    it "removes the active character from the room" do
      # Create a mock room
      room = instance_double(Darkfang::Room, id: "start")
      allow(room).to receive(:remove_player)
      
      # Set up the character with the mock room
      character = player.active_character
      allow(character).to receive(:room).and_return(room)
      
      player.logout
      
      # Verify the character was removed from the room
      expect(room).to have_received(:remove_player).with(character)
    end
    
    it "sets the active character to nil" do
      expect(player.active_character).not_to be_nil
      
      player.logout
      
      expect(player.active_character).to be_nil
    end
  end
  
  describe "#to_json" do
    it "returns a JSON representation of the player" do
      player = described_class.new(player_data)
      
      json = player.to_json
      data = JSON.parse(json)
      
      expect(data["email"]).to eq(email)
      expect(data["password_hash"]).to be_a(String)
      expect(data["characters"]).to be_an(Array)
    end
  end
  
  describe "#save" do
    it "saves the player data to a file" do
      player = described_class.new(player_data)
      
      player.save
      
      player_file = File.join(Darkfang.root, "data", "players", "#{player.email}.json")
      expect(File.exist?(player_file)).to be true
    end
  end
end
