# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Command do
  let(:name) { "test" }
  let(:description) { "A test command" }
  let(:args) { ["arg1"] }
  let(:block) { proc { |player, args| "Command executed with #{args.join(', ')}" } }
  
  subject { described_class.new(name, description, args, &block) }
  
  describe "#initialize" do
    it "creates a command with the given attributes" do
      expect(subject.name).to eq(name)
      expect(subject.description).to eq(description)
      expect(subject.args).to eq(args)
    end
    
    it "creates a command without args" do
      command = described_class.new(name, description, &block)
      expect(command.args).to eq([])
    end
  end
  
  describe "#execute" do
    let(:player) { instance_double("Darkfang::Player") }
    
    it "executes the command block" do
      result = subject.execute(player, ["test_arg"])
      expect(result).to eq("Command executed with test_arg")
    end
  end
end
