# frozen_string_literal: true

module Darkfang
  # Handles individual telnet connections
  class Connection
    attr_reader :player

    def initialize(socket)
      @socket = socket
      @player = nil
      @authenticated = false
      @buffer = ""
      @closed = false
    end

    def handle
      send_welcome_message
      
      until @closed
        data = @socket.recv(1024)
        break if data.empty? # Connection closed by client
        
        @buffer += data
        
        # Process complete lines
        while (line_end = @buffer.index("\r\n") || @buffer.index("\n"))
          line = @buffer[0...line_end].strip
          @buffer = @buffer[(line_end + 1)..-1] || ""
          
          process_input(line)
        end
      end
    rescue => e
      Darkfang.logger.error("Connection error: #{e.message}")
    ensure
      close
    end

    def send_message(message)
      return if @closed
      
      begin
        @socket.puts(message)
      rescue => e
        Darkfang.logger.error("Error sending message: #{e.message}")
        close
      end
    end

    def close
      return if @closed
      
      @closed = true
      
      # Remove player from room
      if @player && @player.room
        @player.room.remove_player(@player)
      end
      
      # Close socket
      begin
        @socket.close
      rescue => e
        Darkfang.logger.error("Error closing socket: #{e.message}")
      end
      
      Darkfang.logger.info("Connection closed")
    end

    private

    def send_welcome_message
      send_message("\r\n\r\n")
      send_message("Welcome to #{Darkfang.config.title}")
      send_message(Darkfang.config.description)
      send_message("\r\n")
      send_message("Please log in or create a new account.")
      send_message("Use '/login <email> <password>' to log in.")
      send_message("Use '/register <email> <password> <confirm_password>' to create a new account.")
      send_message("\r\n")
    end

    def process_input(input)
      return if input.empty?
      
      # Check if input is a command (starts with /)
      if input.start_with?("/")
        process_command(input[1..-1])
      elsif @authenticated
        # If authenticated, treat as say command
        process_command("say #{input}")
      else
        send_message("Please log in first.")
        send_message("Use '/login <email> <password>' to log in.")
        send_message("Use '/register <email> <password> <confirm_password>' to create a new account.")
      end
    end

    def process_command(command_line)
      parts = command_line.split(" ")
      command_name = parts[0].downcase
      args = parts[1..-1] || []
      
      if !@authenticated && !["login", "register"].include?(command_name)
        send_message("Please log in first.")
        return
      end
      
      case command_name
      when "login"
        handle_login(args)
      when "register"
        handle_register(args)
      when "quit", "exit"
        # If player is logged in, log them out of character first
        if @authenticated && @player && @player.active_character
          @player.logout
        end
        send_message("Goodbye!")
        close
      else
        if @authenticated
          # Pass to command processor
          result = Darkfang.game.process_command(@player, command_name, args)
          send_message(result) if result
        end
      end
    end

    def handle_login(args)
      if args.size < 2
        send_message("Usage: /login <email> <password>")
        return
      end
      
      email = args[0]
      password = args[1]
      
      player = Darkfang.game.authenticate_player(email, password)
      
      if player
        @player = player
        @authenticated = true
        @player.connection = self
        
        send_message("Login successful! Welcome back, #{email}.")
        
        if @player.characters.empty?
          send_message("You don't have any characters yet.")
          send_message("Use '/create <character_name>' to create a new character.")
        else
          send_message("Your characters:")
          @player.characters.each_with_index do |character, index|
            send_message("#{index + 1}. #{character.name}")
          end
          send_message("Use '/select <number>' to select a character.")
          send_message("Use '/create <character_name>' to create a new character.")
        end
      else
        send_message("Invalid email or password.")
      end
    end

    def handle_register(args)
      if args.size < 3
        send_message("Usage: /register <email> <password> <confirm_password>")
        return
      end
      
      email = args[0]
      password = args[1]
      confirm_password = args[2]
      
      if password != confirm_password
        send_message("Passwords do not match.")
        return
      end
      
      if Darkfang.game.player_exists?(email)
        send_message("A player with that email already exists.")
        return
      end
      
      player = Darkfang.game.create_player(email, password)
      
      if player
        @player = player
        @authenticated = true
        @player.connection = self
        
        send_message("Registration successful! Welcome, #{email}.")
        send_message("Use '/create <character_name>' to create a new character.")
      else
        send_message("Error creating player.")
      end
    end
  end
end
