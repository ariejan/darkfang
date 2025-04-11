# frozen_string_literal: true

require 'sinatra/base'
require 'faye/websocket'
require 'json'
require 'erb'

module Darkfang
  module Web
    # Web server for Darkfang MUD
    class Server
      attr_reader :host, :port, :connections

      def initialize(host, port)
        @host = host
        @port = port
        @connections = {}
        @running = false
        @server = nil
        @thread = nil
      end

      def start
        return if @running

        # Configure Sinatra app
        app = Class.new(Sinatra::Base) do
          set :public_folder, File.join(File.dirname(__FILE__), 'public')
          set :views, File.join(File.dirname(__FILE__), 'views')
          set :server, 'thin'
          
          # Routes
          get '/' do
            erb :index, locals: { 
              title: Darkfang.config.title || 'Darkfang MUD',
              colors: Darkfang.config.colors || {}
            }
          end
          
          get '/game' do
            erb :game, locals: { 
              title: Darkfang.config.title || 'Darkfang MUD',
              colors: Darkfang.config.colors || {}
            }
          end
        end

        # Configure WebSocket middleware
        app.use(WebSocketMiddleware, self)

        # Start the web server in a separate thread
        @thread = Thread.new do
          Rack::Handler::Thin.run(app, Host: @host, Port: @port) do |server|
            @server = server
          end
        end

        @running = true
        Darkfang.logger.info("Web UI server started on #{@host}:#{@port}")
      end

      def stop
        return unless @running

        @running = false
        
        # Close all connections
        @connections.each_value do |connection|
          connection[:ws].close if connection[:ws]
          if connection[:player] && connection[:player].connection.is_a?(WebConnection)
            connection[:player].connection = nil
          end
        end
        @connections.clear
        
        # Stop the server
        @server.stop! if @server
        
        # Stop the thread
        @thread.kill if @thread

        Darkfang.logger.info("Web UI server stopped")
      end
      
      def register_connection(ws)
        connection_id = SecureRandom.uuid
        @connections[connection_id] = { ws: ws, player: nil }
        connection_id
      end
      
      def unregister_connection(connection_id)
        connection = @connections[connection_id]
        if connection && connection[:player]
          player = connection[:player]
          if player.active_character
            player.logout
          end
          player.connection = nil
        end
        @connections.delete(connection_id)
      end
      
      def handle_message(connection_id, message)
        connection = @connections[connection_id]
        return unless connection
        
        begin
          data = JSON.parse(message)
          
          case data['type']
          when 'login'
            handle_login(connection, data)
          when 'register'
            handle_register(connection, data)
          when 'command'
            handle_command(connection, data)
          when 'select_character'
            handle_select_character(connection, data)
          when 'create_character'
            handle_create_character(connection, data)
          when 'logout'
            handle_logout(connection)
          end
        rescue JSON::ParserError => e
          send_error(connection[:ws], "Invalid message format: #{e.message}")
        rescue => e
          Darkfang.logger.error("Error handling WebSocket message: #{e.message}")
          send_error(connection[:ws], "Server error: #{e.message}")
        end
      end
      
      private
      
      def handle_login(connection, data)
        email = data['email']
        password = data['password']
        
        player = Darkfang.game.authenticate_player(email, password)
        if player
          connection[:player] = player
          player.connection = WebConnection.new(connection[:ws])
          
          characters = player.characters.map.with_index do |char, index|
            { index: index, name: char.name }
          end
          
          send_message(connection[:ws], {
            type: 'login_success',
            characters: characters
          })
        else
          send_error(connection[:ws], "Invalid email or password")
        end
      end
      
      def handle_register(connection, data)
        email = data['email']
        password = data['password']
        
        player = Darkfang.game.create_player(email, password)
        if player
          connection[:player] = player
          player.connection = WebConnection.new(connection[:ws])
          
          send_message(connection[:ws], {
            type: 'register_success'
          })
        else
          send_error(connection[:ws], "Email already in use")
        end
      end
      
      def handle_command(connection, data)
        player = connection[:player]
        return send_error(connection[:ws], "Not logged in") unless player
        return send_error(connection[:ws], "No active character") unless player.active_character
        
        command = data['command'].to_s.strip
        return if command.empty?
        
        # Process the command
        if command.start_with?('/')
          cmd = command[1..-1].split(' ')
          cmd_name = cmd.shift
          result = Darkfang.game.process_command(player, cmd_name, cmd)
          send_message(connection[:ws], {
            type: 'command_result',
            result: result
          })
        else
          # Treat as say command if no slash
          result = Darkfang.game.process_command(player, 'say', [command])
          send_message(connection[:ws], {
            type: 'command_result',
            result: result
          })
        end
      end
      
      def handle_select_character(connection, data)
        player = connection[:player]
        return send_error(connection[:ws], "Not logged in") unless player
        
        index = data['index'].to_i
        result = player.select_character(index)
        
        send_message(connection[:ws], {
          type: 'command_result',
          result: result
        })
      end
      
      def handle_create_character(connection, data)
        player = connection[:player]
        return send_error(connection[:ws], "Not logged in") unless player
        
        name = data['name'].to_s.strip
        return send_error(connection[:ws], "Invalid character name") if name.empty?
        
        result = player.create_character(name)
        
        send_message(connection[:ws], {
          type: 'command_result',
          result: result
        })
      end
      
      def handle_logout(connection)
        player = connection[:player]
        return unless player
        
        if player.active_character
          player.logout
        end
        
        player.connection = nil
        connection[:player] = nil
        
        send_message(connection[:ws], {
          type: 'logout_success'
        })
      end
      
      def send_message(ws, data)
        ws.send(JSON.generate(data))
      rescue => e
        Darkfang.logger.error("Error sending WebSocket message: #{e.message}")
      end
      
      def send_error(ws, message)
        send_message(ws, {
          type: 'error',
          message: message
        })
      end
    end
    
    # WebSocket connection for web clients
    class WebConnection
      def initialize(ws)
        @ws = ws
      end
      
      def send_message(message)
        @ws.send(JSON.generate({
          type: 'game_message',
          message: message
        }))
      rescue => e
        Darkfang.logger.error("Error sending message to web client: #{e.message}")
      end
      
      def close
        @ws.close
      rescue => e
        Darkfang.logger.error("Error closing WebSocket connection: #{e.message}")
      end
    end
    
    # WebSocket middleware for Sinatra
    class WebSocketMiddleware
      def initialize(app, server)
        @app = app
        @server = server
      end
      
      def call(env)
        if Faye::WebSocket.websocket?(env)
          ws = Faye::WebSocket.new(env)
          connection_id = @server.register_connection(ws)
          
          ws.on :open do |event|
            # Send initial connection message
            ws.send(JSON.generate({
              type: 'connected',
              connection_id: connection_id
            }))
          end
          
          ws.on :message do |event|
            @server.handle_message(connection_id, event.data)
          end
          
          ws.on :close do |event|
            @server.unregister_connection(connection_id)
            ws = nil
          end
          
          # Return async Rack response
          ws.rack_response
        else
          @app.call(env)
        end
      end
    end
  end
end
