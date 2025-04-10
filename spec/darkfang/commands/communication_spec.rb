# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Commands::Say do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("say")
      expect(subject.description).to eq("Say something to everyone in the room")
      expect(subject.args).to eq(["message"])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls say on the player with the specified message" do
      expect(player).to receive(:say).with("Hello, world!")
      subject.execute(player, ["Hello,", "world!"])
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

RSpec.describe Darkfang::Commands::Shout do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("shout")
      expect(subject.description).to eq("Shout something to everyone in the game")
      expect(subject.args).to eq(["message"])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls shout on the player with the specified message" do
      expect(player).to receive(:shout).with("Hello, world!")
      subject.execute(player, ["Hello,", "world!"])
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
