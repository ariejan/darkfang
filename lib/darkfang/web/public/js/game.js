$(document).ready(function() {
  // Game state
  let socket;
  let connectionId;
  let commandHistory = [];
  let historyIndex = -1;
  let characterName = 'Not logged in';
  
  // DOM elements
  const $gameOutput = $('#game-output');
  const $commandInput = $('#command-input');
  const $commandForm = $('#command-form');
  const $characterName = $('#character-name');
  const $logoutButton = $('#logout-button');
  
  // Initialize the game interface
  function init() {
    // Connect to WebSocket
    connectWebSocket();
    
    // Set up event handlers
    setupEventHandlers();
    
    // Check if we need to show character selection
    const characters = JSON.parse(sessionStorage.getItem('characters') || '[]');
    if (characters.length > 0) {
      appendSystemMessage('Please select a character:');
      characters.forEach(char => {
        appendSystemMessage(`${char.index}: ${char.name}`);
      });
      appendSystemMessage('Type /select <index> to select a character or /create <name> to create a new one');
    } else {
      appendSystemMessage('Welcome to Darkfang MUD!');
      appendSystemMessage('Please create a character with /create <name>');
    }
  }
  
  // Connect to WebSocket server
  function connectWebSocket() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}`;
    
    socket = new WebSocket(wsUrl);
    
    socket.onopen = function() {
      appendSystemMessage('Connected to server');
    };
    
    socket.onmessage = function(event) {
      const data = JSON.parse(event.data);
      console.log('Received message:', data);
      
      switch(data.type) {
        case 'connected':
          connectionId = data.connection_id;
          break;
          
        case 'game_message':
          appendGameMessage(data.message);
          break;
          
        case 'command_result':
          appendGameMessage(data.result);
          break;
          
        case 'error':
          appendErrorMessage(data.message);
          break;
          
        case 'logout_success':
          // Redirect to login page
          window.location.href = '/';
          break;
      }
    };
    
    socket.onclose = function() {
      appendErrorMessage('Disconnected from server. Trying to reconnect...');
      // Try to reconnect after 5 seconds
      setTimeout(connectWebSocket, 5000);
    };
    
    socket.onerror = function(error) {
      console.error('WebSocket error:', error);
      appendErrorMessage('Connection error');
    };
  }
  
  // Set up event handlers
  function setupEventHandlers() {
    // Command form submission
    $commandForm.on('submit', function(e) {
      e.preventDefault();
      
      const command = $commandInput.val().trim();
      if (!command) return;
      
      // Add to command history
      commandHistory.unshift(command);
      if (commandHistory.length > 50) {
        commandHistory.pop();
      }
      historyIndex = -1;
      
      // Clear input
      $commandInput.val('');
      
      // Echo command to output
      appendUserCommand(command);
      
      // Process command
      processCommand(command);
    });
    
    // Command history navigation
    $commandInput.on('keydown', function(e) {
      if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (historyIndex < commandHistory.length - 1) {
          historyIndex++;
          $commandInput.val(commandHistory[historyIndex]);
        }
      } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (historyIndex > 0) {
          historyIndex--;
          $commandInput.val(commandHistory[historyIndex]);
        } else if (historyIndex === 0) {
          historyIndex = -1;
          $commandInput.val('');
        }
      }
    });
    
    // Quick command buttons
    $('.quick-cmd').on('click', function() {
      const command = $(this).data('cmd');
      $commandInput.val(command);
      $commandForm.submit();
    });
    
    // Logout button
    $logoutButton.on('click', function() {
      if (confirm('Are you sure you want to logout?')) {
        sendToServer({
          type: 'logout'
        });
      }
    });
  }
  
  // Process command
  function processCommand(command) {
    if (!socket || socket.readyState !== WebSocket.OPEN || !connectionId) {
      appendErrorMessage('Not connected to server');
      return;
    }
    
    // Special client-side commands
    if (command === '/clear') {
      $gameOutput.empty();
      return;
    }
    
    // Handle character selection
    if (command.startsWith('/select ')) {
      const index = parseInt(command.substring(8).trim());
      sendToServer({
        type: 'select_character',
        index: index
      });
      return;
    }
    
    // Handle character creation
    if (command.startsWith('/create ')) {
      const name = command.substring(8).trim();
      sendToServer({
        type: 'create_character',
        name: name
      });
      return;
    }
    
    // Send command to server
    sendToServer({
      type: 'command',
      command: command
    });
  }
  
  // Send data to server
  function sendToServer(data) {
    socket.send(JSON.stringify(data));
  }
  
  // Append messages to the game output
  function appendMessage(className, sender, content) {
    const timestamp = new Date().toLocaleTimeString();
    const $message = $('<div class="message ' + className + '"></div>');
    $message.html(
      '<span class="timestamp">[' + timestamp + ']</span> ' +
      '<span class="sender">' + sender + ':</span> ' +
      '<span class="content">' + formatMessage(content) + '</span>'
    );
    
    $gameOutput.append($message);
    scrollToBottom();
    
    // Update character name if it's in the message
    if (content.includes('You are now playing as')) {
      const match = content.match(/You are now playing as ([^.]+)/);
      if (match && match[1]) {
        characterName = match[1].trim();
        $characterName.text(characterName);
      }
    }
  }
  
  function appendSystemMessage(content) {
    appendMessage('system', 'System', content);
  }
  
  function appendGameMessage(content) {
    appendMessage('game', 'Game', content);
  }
  
  function appendErrorMessage(content) {
    appendMessage('error', 'Error', content);
  }
  
  function appendUserCommand(content) {
    appendMessage('user', 'You', content);
  }
  
  // Format message for display
  function formatMessage(message) {
    // Replace newlines with <br>
    return message.replace(/\n/g, '<br>');
  }
  
  // Scroll to the bottom of the game output
  function scrollToBottom() {
    $gameOutput.scrollTop($gameOutput[0].scrollHeight);
  }
  
  // Initialize the game
  init();
});
