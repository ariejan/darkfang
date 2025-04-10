# frozen_string_literal: true

require_relative "server"

module Darkfang
  module CLI
    class Base < Thor
      desc "serve", "Start the Darkfang server"
      option :host, type: :string, aliases: "-H", desc: "Server host"
      option :port, type: :numeric, aliases: "-p", desc: "Server port"
      def serve
        host = options[:host] || Darkfang.config&.server_host || "0.0.0.0"
        port = options[:port] || Darkfang.config&.server_port || 4532

        begin
          # Load configuration
          Darkfang.load_config
          
          # Start server
          server = Darkfang::Server.new(host, port)
          server.start
        rescue => e
          Darkfang.logger.error("Error starting server: #{e.message}")
          puts "Error starting server: #{e.message}"
          exit 1
        end
      end

      desc "check", "Validate the Darkfang configuration and data"
      def check
        begin
          validator = Darkfang::Validator.new
          validator.validate!
          puts "Configuration and data are valid."
        rescue Darkfang::ValidationError => e
          puts "Validation errors:"
          puts e.message
          exit 1
        end
      end
    end
  end
end
