# frozen_string_literal: true

module Darkfang
  # Telnet server for Darkfang
  class Server
    attr_reader :host, :port, :connections

    def initialize(host, port)
      @host = host
      @port = port
      @connections = []
      @running = false
      @server = nil
    end

    def start
      return if @running

      Darkfang.load_config
      Darkfang.init_world
      Darkfang.init_game

      @server = TCPServer.new(@host, @port)
      @running = true

      Darkfang.logger.info("Server started on #{@host}:#{@port}")
      Darkfang.logger.info("Game title: #{Darkfang.config.title}")

      # Start automation thread
      @automation_thread = Thread.new do
        while @running
          begin
            Darkfang.world.run_automations
          rescue => e
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
              begin
                connection.handle
              rescue => e
                Darkfang.logger.error("Error handling connection: #{e.message}")
              ensure
                @connections.delete(connection)
                connection.close
              end
            end
          rescue => e
            Darkfang.logger.error("Error accepting connection: #{e.message}")
            break if !@running
          end
        end
      end

      # Wait for the accept thread to finish
      @accept_thread.join
    end

    def stop
      return unless @running

      @running = false
      
      # Close all connections
      @connections.each(&:close)
      @connections.clear
      
      # Close the server
      @server.close if @server
      
      # Stop the automation thread
      @automation_thread.kill if @automation_thread
      
      # Stop the accept thread
      @accept_thread.kill if @accept_thread

      Darkfang.logger.info("Server stopped")
    end
  end
end
