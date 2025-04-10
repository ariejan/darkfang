# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Commands::Go do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("go")
      expect(subject.description).to eq("Move in a direction")
      expect(subject.args).to eq(["direction"])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls move on the player with the specified direction" do
      expect(player).to receive(:move).with("north")
      subject.execute(player, ["north"])
    end
  end
  
  describe ".register" do
    let(:game) { instance_double("Darkfang::Game") }
    
    it "registers the command and direction commands with the game" do
      expect(game).to receive(:register_command).with(an_instance_of(described_class))
      
      # Direction commands
      %w[north south east west up down].each do |direction|
        expect(game).to receive(:register_command).with(an_instance_of(Darkfang::Commands::Direction))
      end
      
      # Shorthand direction commands
      %w[n s e w u d].each do |shorthand|
        expect(game).to receive(:register_command).with(an_instance_of(Darkfang::Commands::Direction))
      end
      
      described_class.register(game)
    end
  end
end

RSpec.describe Darkfang::Commands::Direction do
  let(:direction) { "north" }
  subject { described_class.new(direction) }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq(direction)
      expect(subject.description).to eq("Move north")
      expect(subject.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls move on the player with the specified direction" do
      expect(player).to receive(:move).with(direction)
      subject.execute(player, [])
    end
  end
end
