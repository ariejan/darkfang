# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::CLI::Server do
  describe "#start" do
    it "forwards to the Base class serve command" do
      # Create a mock for the Base class
      base_instance = instance_double(Darkfang::CLI::Base)
      allow(Darkfang::CLI::Base).to receive(:new).and_return(base_instance)
      allow(base_instance).to receive(:invoke)
      
      # Call the start method with the correct command
      described_class.start(["start"])
      
      # Verify that Base#invoke was called with the serve command
      expect(base_instance).to have_received(:invoke).with(:serve, [], { host: "0.0.0.0", port: 4532 })
    end
  end
end
