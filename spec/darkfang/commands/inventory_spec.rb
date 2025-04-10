# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Commands::Inventory do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("inventory")
      expect(subject.description).to eq("View your inventory")
      expect(subject.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls show_inventory on the player" do
      expect(player).to receive(:show_inventory)
      subject.execute(player, [])
    end
  end
  
  describe ".register" do
    let(:game) { instance_double("Darkfang::Game") }
    
    it "registers the command and shorthand with the game" do
      expect(game).to receive(:register_command).with(an_instance_of(described_class))
      expect(game).to receive(:register_command).with(an_instance_of(Darkfang::Commands::InventoryShorthand))
      described_class.register(game)
    end
  end
end

RSpec.describe Darkfang::Commands::InventoryShorthand do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("i")
      expect(subject.description).to eq("View your inventory")
      expect(subject.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls show_inventory on the player" do
      expect(player).to receive(:show_inventory)
      subject.execute(player, [])
    end
  end
end

RSpec.describe Darkfang::Commands::Take do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("take")
      expect(subject.description).to eq("Take an item")
      expect(subject.args).to eq(["item"])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls take_item on the player with the specified item name" do
      expect(player).to receive(:take_item).with("magic sword")
      subject.execute(player, ["magic", "sword"])
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

RSpec.describe Darkfang::Commands::Drop do
  subject { described_class.new }
  
  describe "#initialize" do
    it "creates a command with the correct attributes" do
      expect(subject.name).to eq("drop")
      expect(subject.description).to eq("Drop an item")
      expect(subject.args).to eq(["item"])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "calls drop_item on the player with the specified item name" do
      expect(player).to receive(:drop_item).with("magic sword")
      subject.execute(player, ["magic", "sword"])
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
