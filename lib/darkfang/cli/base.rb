# frozen_string_literal: true

module Darkfang
  module CLI
    class Base < Thor
      desc "serve", "Start the Darkfang server"
      option :host, type: :string, aliases: "-H", desc: "Server host"
      option :port, type: :numeric, aliases: "-p", desc: "Server port"
      option :web, type: :boolean, default: true, desc: "Enable web UI"
      option :web_port, type: :numeric, desc: "Web UI port (default: telnet port + 1)"
      def serve
        host = options[:host] || Darkfang.config&.server_host || "0.0.0.0"
        port = options[:port] || Darkfang.config&.server_port || 4532
        web_enabled = if options[:web].nil?
                        Darkfang.config&.web_enabled.nil? || Darkfang.config&.web_enabled
                      else
                        options[:web]
                      end
        web_port = options[:web_port] || Darkfang.config&.web_port || (port + 1)

        begin
          # Load configuration
          Darkfang.load_config

          # Start server
          server = Darkfang::Server.new(host, port, web_enabled: web_enabled, web_port: web_port)

          # Set up signal trap for Ctrl+C
          trap("INT") do
            Darkfang.logger.info("Shutting down server...")
            server.stop
            exit
          end

          # Start the server
          server.start

          # Wait for server to finish
          Thread.current.join
        rescue StandardError => e
          Darkfang.logger.error("Error starting server: #{e.message}")
          Darkfang.logger.error("Stack trace: #{e.backtrace.join("\n")}")
          exit 1
        end
      end

      desc "check", "Validate the Darkfang configuration and data"
      def check
        validator = Darkfang::Validator.new
        validator.validate!
        Darkfang.logger.info("Configuration and data are valid.")
      rescue Darkfang::ValidationError => e
        Darkfang.logger.error("Validation errors:")
        Darkfang.logger.error(e.message)
        exit 1
      end
    end
  end
end
