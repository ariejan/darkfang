# frozen_string_literal: true

require "spec_helper"

RSpec.describe Darkfang do
  it "has a version number" do
    expect(Darkfang::VERSION).not_to be_nil
  end
end
