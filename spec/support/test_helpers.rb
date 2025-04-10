# frozen_string_literal: true

module TestHelpers
  # Create a temporary directory for test data
  def setup_test_directory
    @test_dir = File.join(Dir.tmpdir, "darkfang_test_#{Time.now.to_i}")
    
    # Create necessary directories
    %w[data data/players data/characters rooms items].each do |dir|
      FileUtils.mkdir_p(File.join(@test_dir, dir))
    end
    
    # Create a basic config file
    File.write(File.join(@test_dir, "darkfang.yml"), {
      "server" => {
        "host" => "127.0.0.1",
        "port" => 4532
      },
      "game" => {
        "title" => "Test MUD",
        "description" => "A test MUD for RSpec",
        "start_room" => "start"
      },
      "directories" => {
        "rooms" => "rooms",
        "items" => "items"
      }
    }.to_yaml)
    
    # Create a basic room
    File.write(File.join(@test_dir, "rooms", "start.yml"), {
      "room" => {
        "name" => "Test Room",
        "description" => "A test room for RSpec",
        "automation" => [
          {
            "type" => "cron",
            "cron" => "* * * * *",
            "command" => "echo 'Test automation'"
          }
        ]
      }
    }.to_yaml)
    
    # Create a basic item
    File.write(File.join(@test_dir, "items", "test_item.yml"), {
      "item" => {
        "name" => "Test Item",
        "description" => "A test item for RSpec",
        "weight" => 1,
        "type" => "weapon"
      }
    }.to_yaml)
    
    # Set Darkfang root to our test directory
    Darkfang.root = @test_dir
  end
  
  # Clean up the test directory
  def cleanup_test_directory
    FileUtils.rm_rf(@test_dir) if @test_dir && Dir.exist?(@test_dir)
    Darkfang.reset
  end
  
  # Create a test player
  def create_test_player(email = "test@example.com", password = "password")
    player_data = {
      "email" => email,
      "password_hash" => BCrypt::Password.create(password),
      "characters" => []
    }
    
    player = Darkfang::Player.new(player_data)
    
    # Save player to file
    players_dir = File.join(Darkfang.root, "data", "players")
    player_file = File.join(players_dir, "#{player.email}.json")
    
    File.write(player_file, player.to_json)
    
    player
  end
  
  # Create a test character
  def create_test_character(player, name = "TestCharacter")
    character_id = SecureRandom.uuid
    
    character_data = {
      "id" => character_id,
      "name" => name,
      "health" => 100,
      "max_health" => 100,
      "inventory" => [],
      "room_id" => "start"
    }
    
    character = Darkfang::Character.new(character_data, player)
    
    # Save character to file
    characters_dir = File.join(Darkfang.root, "data", "characters")
    character_file = File.join(characters_dir, "#{character.id}.json")
    
    File.write(character_file, character.to_json)
    
    # Update player data
    player.instance_variable_get(:@characters) << character
    
    character
  end
  
  # Mock socket for testing connections
  class MockSocket
    attr_reader :messages
    
    def initialize
      @messages = []
      @closed = false
    end
    
    def puts(message)
      @messages << message
    end
    
    def close
      @closed = true
    end
    
    def closed?
      @closed
    end
    
    def recv(*)
      "test input\r\n"
    end
  end
end
