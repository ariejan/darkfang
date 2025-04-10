# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Commands::Base do
  let(:name) { "test" }
  let(:description) { "A test command" }
  let(:args) { ["arg1"] }
  
  subject { described_class.new(name, description, args) }
  
  describe "#initialize" do
    it "creates a command with the given attributes" do
      expect(subject.name).to eq(name)
      expect(subject.description).to eq(description)
      expect(subject.args).to eq(args)
    end
    
    it "creates a command without args" do
      command = described_class.new(name, description)
      expect(command.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "raises NotImplementedError" do
      expect { subject.execute(player, ["test_arg"]) }.to raise_error(NotImplementedError)
    end
  end
  
  describe ".register" do
    let(:game) { instance_double("Darkfang::Game") }
    
    it "raises NotImplementedError" do
      expect { described_class.register(game) }.to raise_error(NotImplementedError)
    end
  end
end
