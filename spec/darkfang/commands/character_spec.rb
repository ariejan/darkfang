# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Commands::Create do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("create")
      expect(subject.description).to eq("Create a new character")
      expect(subject.args).to eq(["name"])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls create_character on the player with the specified name" do
      expect(player).to receive(:create_character).with("Test Character")
      subject.execute(player, ["Test", "Character"])
    end
  end
  
  describe ".register" do
    let(:game) { instance_double("Darkfang::Game") }
    
    it "registers the command with the game" do
      expect(game).to receive(:register_command).with(an_instance_of(described_class))
      described_class.register(game)
    end
  end
end

RSpec.describe Darkfang::Commands::Select do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("select")
      expect(subject.description).to eq("Select a character")
      expect(subject.args).to eq(["number"])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls select_character on the player with the specified index" do
      expect(player).to receive(:select_character).with(1)
      subject.execute(player, ["2"])
    end
  end
  
  describe ".register" do
    let(:game) { instance_double("Darkfang::Game") }
    
    it "registers the command with the game" do
      expect(game).to receive(:register_command).with(an_instance_of(described_class))
      described_class.register(game)
    end
  end
end

RSpec.describe Darkfang::Commands::Logout do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("logout")
      expect(subject.description).to eq("Return to character selection")
      expect(subject.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls logout on the player" do
      expect(player).to receive(:logout)
      subject.execute(player, [])
    end
  end
  
  describe ".register" do
    let(:game) { instance_double("Darkfang::Game") }
    
    it "registers the command with the game" do
      expect(game).to receive(:register_command).with(an_instance_of(described_class))
      described_class.register(game)
    end
  end
end
