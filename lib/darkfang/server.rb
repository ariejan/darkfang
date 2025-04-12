# frozen_string_literal: true

module Darkfang
  # Server for Darkfang
  class Server
    attr_reader :host, :port, :connections, :web_server

    def initialize(host, port, web_enabled: true, web_port: nil)
      @host = host
      @port = port
      @web_enabled = web_enabled
      @web_port = web_port || (port + 1)
      @connections = []
      @running = false
      @server = nil
      @web_server = nil
    end

    def start
      return if @running

      Darkfang.load_config
      Darkfang.init_world
      Darkfang.init_game

      @server = TCPServer.new(@host, @port)
      @running = true

      Darkfang.logger.info("Game title: #{Darkfang.config.title}")
      Darkfang.logger.info("Telnet server started on #{@host}:#{@port}")

      # Start web server if enabled
      if @web_enabled
        require_relative "web/server"
        @web_server = Darkfang::Web::Server.new(@host, @web_port)
        @web_server.start
        Darkfang.logger.info("Web UI available at http://#{@host == "0.0.0.0" ? "localhost" : @host}:#{@web_port}")
      end

      # Start automation thread
      @automation_thread = Thread.new do
        while @running
          begin
            Darkfang.world.run_automations
          rescue StandardError => e
            Darkfang.logger.error("Error in automation: #{e.message}")
          end
          sleep 1
        end
      end

      # Accept connections
      @accept_thread = Thread.new do
        while @running
          begin
            client = @server.accept
            connection = Connection.new(client)
            @connections << connection

            # Start a new thread for each connection
            Thread.new do
              connection.handle
            rescue StandardError => e
              Darkfang.logger.error("Error handling connection: #{e.message}")
            ensure
              @connections.delete(connection)
              connection.close
            end
          rescue StandardError => e
            Darkfang.logger.error("Error accepting connection: #{e.message}")
            break unless @running
          end
        end
      end

      # Return immediately after starting threads
      @accept_thread
    end

    def stop
      return unless @running

      @running = false

      # Close all connections
      @connections.each(&:close)
      @connections.clear

      # Stop the web server if enabled
      @web_server&.stop if @web_enabled

      # Stop the automation thread
      @automation_thread&.kill

      # Stop the accept thread
      @accept_thread&.kill

      Darkfang.logger.info("Server stopped")
    end
  end
end
