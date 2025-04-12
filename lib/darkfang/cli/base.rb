# frozen_string_literal: true

module Darkfang
  module CLI
    class Base < Thor
      class_option :directory, type: :string, aliases: "-d", desc: "Path to the Darkfang data directory"

      desc "serve", "Start the Darkfang server"
      option :host, type: :string, aliases: "-H", desc: "Server host"
      option :port, type: :numeric, aliases: "-p", desc: "Server port"
      option :web, type: :boolean, default: true, desc: "Enable web UI"
      option :web_port, type: :numeric, desc: "Web UI port (default: telnet port + 1)"
      def serve
        setup_data_directory
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

          # Set up signal handling
          @shutdown_requested = false
          trap("INT") do
            puts
            @shutdown_requested = true
          end

          # Start the server
          server.start

          # Main loop
          sleep 0.1 until @shutdown_requested

          # Handle shutdown
          Darkfang.logger.info("Stopping server... (Ctrl+C pressed)")
          server.stop
          exit
        rescue StandardError => e
          Darkfang.logger.error("Error starting server: #{e.message}")
          Darkfang.logger.error("Stack trace: #{e.backtrace.join("\n")}")
          exit 1
        end
      end

      desc "check", "Validate the Darkfang configuration and data"
      def check
        setup_data_directory
        begin
          validator = Darkfang::Validator.new
          validator.validate!
          Darkfang.logger.info("Configuration and data are valid.")
        rescue Darkfang::ValidationError => e
          Darkfang.logger.error("Validation errors:")
          Darkfang.logger.error(e.message)
          exit 1
        end
      end

      private

      def setup_data_directory
        dir = options[:directory] || Dir.pwd
        raise ConfigurationError, "Directory not found: #{dir}" unless File.directory?(dir)

        Darkfang.root = File.expand_path(dir)
      end
    end
  end
end
