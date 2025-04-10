# frozen_string_literal: true

require "darkfang"
require "tmpdir"
require "fileutils"
require "yaml"
require "json"
require "bcrypt"
require "logger"

# Disable logging during tests
module Darkfang
  def self.logger
    @test_logger ||= Logger.new(nil)
  end
end

# Explicitly require command files
require "darkfang/commands"
require "darkfang/commands/base"
require "darkfang/commands/look"
require "darkfang/commands/movement"
require "darkfang/commands/communication"
require "darkfang/commands/character"
require "darkfang/commands/inventory"
require "darkfang/commands/help"

# Load test helpers
require_relative "support/test_helpers"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  # Include test helpers
  config.include TestHelpers
  
  # Reset Darkfang between tests
  config.after(:each) do
    Darkfang.reset
  end
end
