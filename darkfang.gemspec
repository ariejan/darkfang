# frozen_string_literal: true

require_relative "lib/darkfang/version"

Gem::Specification.new do |spec|
  spec.name = "darkfang"
  spec.version = Darkfang::VERSION
  spec.authors = ["Ariejan de Vroom"]
  spec.email = ["ariejan@devroom.io"]

  spec.summary = "Darkfang is a lightweight, Ruby-based MUD system designed to help " \
                 "developers quickly set up and build their own multi-user dungeon " \
                 "(MUD) games."
  spec.description = "Darkfang provides the core framework needed to create and manage " \
                     "a text-based multiplayer game. It handles essential features like " \
                     "player connections, command parsing, game loops, and basic world " \
                     "management, allowing developers to focus on game design and content " \
                     "creation. Darkfang is not a complete game but a powerful foundation, " \
                     "giving you the flexibility to build your own MUD with custom assets, " \
                     "mechanics, and storytelling elements. Whether you’re an experienced " \
                     "Ruby developer or new to MUD development, Darkfang makes it easy to " \
                     "bring your text-based world to life."
  spec.homepage = "https://github.com/ariejan/darkfang"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/ariejan/darkfang",
    "bug_tracker_uri" => "https://github.com/ariejan/darkfang/issues",
    "changelog_uri" => "https://github.com/ariejan/darkfang/blob/master/CHANGELOG.md",

    "rubygems_mfa_required" => "true",
    "allowed_push_host" => "https://rubygems.org"
  }

  spec.rdoc_options = ["--charset=UTF-8"]

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob([
    "lib/**/*.rb",
    "lib/darkfang/web/**/*",
    "exe/**/*",
    "*.md",
    "LICENSE.txt"
  ])
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("thor", "~> 1.3", ">= 1.3.1")
  spec.add_dependency("bcrypt", "~> 3.1")
  spec.add_dependency("sinatra", "~> 3.0")
  spec.add_dependency("thin", "~> 1.8")
  spec.add_dependency("faye-websocket", "~> 0.11")
  spec.add_dependency("logger", "~> 1.6")
end
