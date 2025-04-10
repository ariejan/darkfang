# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Commands::Help do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("help")
      expect(subject.description).to eq("Show available commands")
      expect(subject.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    let(:command1) { instance_double("Darkfang::Command", name: "test1", description: "Test command 1") }
    let(:command2) { instance_double("Darkfang::Command", name: "test2", description: "Test command 2") }
    let(:game) { instance_double("Darkfang::Game", commands: { "test1" => command1, "test2" => command2 }) }
    
    before do
      allow(Darkfang).to receive(:game).and_return(game)
    end
    
    it "returns a formatted list of available commands" do
      result = subject.execute(player, [])
      expect(result).to include("Available commands:")
      expect(result).to include("/test1 - Test command 1")
      expect(result).to include("/test2 - Test command 2")
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
