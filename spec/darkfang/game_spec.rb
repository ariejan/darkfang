# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Game do
  before do
    setup_test_directory
    Darkfang.load_config
  end
  
  after do
    cleanup_test_directory
  end
  
  describe "#initialize" do
    it "initializes a new game with empty players and commands" do
      # Mock the methods that are called in initialize
      allow_any_instance_of(described_class).to receive(:create_data_directories)
      allow_any_instance_of(described_class).to receive(:load_players)
      allow_any_instance_of(described_class).to receive(:register_commands)
      
      game = described_class.new
      expect(game.players).to be_a(Hash)
      expect(game.commands).to be_a(Hash)
    end
  end
  
  describe "#register_commands" do
    it "loads and registers all commands" do
      game = described_class.new
      
      expect(Darkfang::Commands).to receive(:load_commands)
      expect(Darkfang::Commands).to receive(:register_all).with(game)
      
      game.register_commands
    end
  end
  
  describe "#register_command" do
    let(:command) { instance_double("Darkfang::Command", name: "test") }
    
    it "registers a command" do
      game = described_class.new
      game.register_command(command)
      
      expect(game.commands["test"]).to eq(command)
    end
  end
  
  describe "#process_command" do
    let(:player) { instance_double("Darkfang::Player") }
    let(:command) { instance_double("Darkfang::Command") }
    
    it "executes a valid command" do
      game = described_class.new
      game.commands["test"] = command
      
      expect(command).to receive(:execute).with(player, ["arg1", "arg2"]).and_return("Command executed")
      
      result = game.process_command(player, "test", ["arg1", "arg2"])
      expect(result).to eq("Command executed")
    end
    
    it "returns an error message for an unknown command" do
      game = described_class.new
      
      result = game.process_command(player, "unknown", [])
      expect(result).to eq("Unknown command: unknown. Type /help for a list of commands.")
    end
  end
  
  describe "#authenticate_player" do
    let(:email) { "test@example.com" }
    let(:password) { "password" }
    
    it "returns nil if the player does not exist" do
      game = described_class.new
      
      result = game.authenticate_player(email, password)
      expect(result).to be_nil
    end
    
    it "returns nil if the password is incorrect" do
      game = described_class.new
      player = create_test_player(email, password)
      game.players[email] = player
      
      result = game.authenticate_player(email, "wrong_password")
      expect(result).to be_nil
    end
    
    it "returns the player if authentication is successful" do
      game = described_class.new
      player = create_test_player(email, password)
      game.players[email] = player
      
      result = game.authenticate_player(email, password)
      expect(result).to eq(player)
    end
  end
  
  describe "#create_player" do
    let(:email) { "test@example.com" }
    let(:password) { "password" }
    
    it "returns nil if the player already exists" do
      game = described_class.new
      player = create_test_player(email, password)
      game.players[email] = player
      
      result = game.create_player(email, password)
      expect(result).to be_nil
    end
    
    it "creates and returns a new player if the email is available" do
      game = described_class.new
      
      # Mock the save_player method to avoid file operations
      allow(game).to receive(:save_player)
      
      result = game.create_player(email, password)
      expect(result).to be_a(Darkfang::Player)
      expect(result.email).to eq(email)
      expect(game.players[email]).to eq(result)
      expect(game).to have_received(:save_player).with(result)
    end
  end
  
  describe "#load_players" do
    it "loads players from files" do
      game = described_class.new
      player = create_test_player
      
      game.load_players
      
      expect(game.players[player.email]).to be_a(Darkfang::Player)
      expect(game.players[player.email].email).to eq(player.email)
    end
  end
  
  describe "#broadcast" do
    let(:player1) { instance_double("Darkfang::Player", connection: double, active_character: double) }
    let(:player2) { instance_double("Darkfang::Player", connection: double, active_character: double) }
    
    it "sends a message to all players" do
      game = described_class.new
      
      # Add players to the game's players hash directly
      players_hash = { "player1" => player1, "player2" => player2 }
      game.instance_variable_set(:@players, players_hash)
      
      expect(player1).to receive(:send_message).with("Test message")
      expect(player2).to receive(:send_message).with("Test message")
      
      game.broadcast("Test message")
    end
    
    it "skips players without a connection" do
      game = described_class.new
      player3 = instance_double("Darkfang::Player", connection: nil, active_character: double)
      
      # Add players to the game's players hash directly
      players_hash = { "player1" => player1, "player2" => player2, "player3" => player3 }
      game.instance_variable_set(:@players, players_hash)
      
      expect(player1).to receive(:send_message).with("Test message")
      expect(player2).to receive(:send_message).with("Test message")
      # Player3 should be skipped because it has no connection
      expect(player3).not_to receive(:send_message)
      
      game.broadcast("Test message")
    end
    
    it "skips players without an active character" do
      game = described_class.new
      player3 = instance_double("Darkfang::Player", connection: double, active_character: nil)
      
      # Add players to the game's players hash directly
      players_hash = { "player1" => player1, "player2" => player2, "player3" => player3 }
      game.instance_variable_set(:@players, players_hash)
      
      expect(player1).to receive(:send_message).with("Test message")
      expect(player2).to receive(:send_message).with("Test message")
      # Player3 should be skipped because it has no active character
      expect(player3).not_to receive(:send_message)
      
      game.broadcast("Test message")
    end
  end
end
