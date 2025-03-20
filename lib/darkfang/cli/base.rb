# frozen_string_literal: true

require_relative "server"

module Darkfang
  module CLI
    class Base < Thor
      desc "server SUBCOMMAND ...ARGS", "Run the Darkfang server"
      subcommand "server", Darkfang::CLI::Server
    end
  end
end
