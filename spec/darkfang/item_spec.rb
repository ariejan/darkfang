# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::Item do
  let(:item_id) { "test_item" }
  let(:item_data) do
    [
      { "name" => "Test Item" },
      { "description" => "A test item for RSpec" },
      { "weight" => 1 },
      { "type" => "weapon" },
      { "attack" => 5 },
      { "defense" => 2 }
    ]
  end
  
  subject { described_class.new(item_id, item_data) }
  
  describe "#initialize" do
    it "initializes an item with the given data" do
      expect(subject.id).to eq(item_id)
      expect(subject.name).to eq("Test Item")
      expect(subject.description).to eq("A test item for RSpec")
      expect(subject.weight).to eq(1)
      expect(subject.type).to eq("weapon")
      expect(subject.attack).to eq(5)
      expect(subject.defense).to eq(2)
    end
  end
  
  describe "#to_s" do
    it "returns a string representation of the item" do
      result = subject.to_s
      
      expect(result).to include("Test Item")
      expect(result).to include("A test item for RSpec")
      expect(result).to include("Weight: 1")
      expect(result).to include("weapon")
    end
  end
end
