# frozen_string_literal: true

module Darkfang
  module CLI
    # This file is kept for backward compatibility
    # The actual server implementation is now in the Base class
    class Server < Thor
      default_task :start

      desc "start", "Start the Darkfang server"
      option :host, type: :string, default: "0.0.0.0", aliases: "-H", desc: "Server host"
      option :port, type: :numeric, default: 4532, aliases: "-p", desc: "Server port"
      def start
        host = options[:host]
        port = options[:port]

        # Forward to the new serve command
        Darkfang::CLI::Base.new.invoke(:serve, [], { host: host, port: port })
      end
    end
  end
end
