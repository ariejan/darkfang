# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang::CLI::Server do
  it "starts the server with default options" do
    expect { described_class.start(["start"]) }.to output("Starting server on 127.0.0.1:4532\n").to_stdout
  end

  it "starts the server with custom host/port options" do
    expect do
      described_class.start(
        ["start", "--host", "0.0.0.0", "--port", "1234"]
      )
    end.to output("Starting server on 0.0.0.0:1234\n").to_stdout
  end
end
