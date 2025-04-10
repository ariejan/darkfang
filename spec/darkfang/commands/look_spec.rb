# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Commands::Look do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("look")
      expect(subject.description).to eq("Look around the current room")
      expect(subject.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls look on the player" do
      expect(player).to receive(:look)
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
