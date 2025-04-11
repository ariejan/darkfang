# Darkfang

Darkfang is a lightweight, Ruby-based MUD system designed to help developers quickly set up and build their own multi-user dungeon(MUD) games. 

It is not based on any previous MUD system.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

### Basic Setup

Darkfang operates on a directory structure similar to Jekyll. Create a new directory for your MUD and add the following files:

```
├── darkfang.yml    # Configuration file
├── rooms/          # Directory containing room definitions
│   └── start.yml   # Starting room (required)
└── items/          # Directory containing item definitions
```

### Running the Server

To start the Darkfang server:

```bash
darkfang serve
```

This will start both the telnet server (default port 4532) and the web UI (default port 4533).

Options:

```bash
# Specify host and port
darkfang serve -H 127.0.0.1 -p 4000

# Disable web UI
darkfang serve --no-web

# Specify web UI port
darkfang serve --web-port 8080
```

### Web UI

Darkfang includes a web-based user interface that runs alongside the traditional telnet interface. Players can connect to the web UI using a modern web browser.

The web UI provides:

- User-friendly interface for playing the MUD
- Authentication and character selection
- Command input with history
- Customizable colors and styling

### Configuration

The `darkfang.yml` file allows you to configure both the telnet server and web UI:

```yaml
server:
  host: 0.0.0.0
  port: 4532

web:
  enabled: true
  port: 4533
  colors:
    primary: "#2c3e50"    # Dark blue-green
    secondary: "#34495e"  # Darker blue-green
    accent: "#e74c3c"     # Red
    text: "#ecf0f1"       # Light gray
    background: "#1a1a1a" # Dark background

darkfang:
  title: My MUD Game
  description: An exciting adventure in a fantasy world.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ariejan/darkfang.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
