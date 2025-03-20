# frozen_string_literal: true

module Darkfang
  module CLI
    # Command to start the Darkfang server
    class Server < Thor
      default_task :start

      desc "start", "Start the Darkfang server"
      option :host, type: :string, default: "127.0.0.1", aliases: "-H", desc: "Server host"
      option :port, type: :numeric, default: 4532, aliases: "-p", desc: "Server port"
      def start
        host = options[:host]
        port = options[:port]

        puts "Starting server on #{host}:#{port}"
      end
    end
  end
end
