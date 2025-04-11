$(document).ready(function() {
  // Tab switching
  $('.tab-button').on('click', function() {
    const tabId = $(this).data('tab');
    
    // Update active tab button
    $('.tab-button').removeClass('active');
    $(this).addClass('active');
    
    // Show the selected tab content
    $('.tab-content').removeClass('active');
    $(`#${tabId}-tab`).addClass('active');
    
    // Clear any status messages
    $('#status-message').removeClass('error success').hide().text('');
  });
  
  // WebSocket connection
  let socket;
  let connectionId;
  
  function connectWebSocket() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}`;
    
    socket = new WebSocket(wsUrl);
    
    socket.onopen = function() {
      console.log('WebSocket connection established');
    };
    
    socket.onmessage = function(event) {
      const data = JSON.parse(event.data);
      console.log('Received message:', data);
      
      switch(data.type) {
        case 'connected':
          connectionId = data.connection_id;
          break;
          
        case 'login_success':
          showStatusMessage('Login successful! Redirecting to game...', 'success');
          // Store characters in session storage for the game page
          sessionStorage.setItem('characters', JSON.stringify(data.characters));
          // Redirect to game page after a short delay
          setTimeout(() => {
            window.location.href = '/game';
          }, 1500);
          break;
          
        case 'register_success':
          showStatusMessage('Registration successful! Please create a character.', 'success');
          // Redirect to game page after a short delay
          setTimeout(() => {
            window.location.href = '/game';
          }, 1500);
          break;
          
        case 'error':
          showStatusMessage(data.message, 'error');
          break;
      }
    };
    
    socket.onclose = function() {
      console.log('WebSocket connection closed');
      // Try to reconnect after 5 seconds
      setTimeout(connectWebSocket, 5000);
    };
    
    socket.onerror = function(error) {
      console.error('WebSocket error:', error);
    };
  }
  
  // Connect to WebSocket server
  connectWebSocket();
  
  // Login form submission
  $('#login-form').on('submit', function(e) {
    e.preventDefault();
    
    const email = $('#login-email').val();
    const password = $('#login-password').val();
    
    if (!email || !password) {
      showStatusMessage('Please enter both email and password', 'error');
      return;
    }
    
    if (!socket || socket.readyState !== WebSocket.OPEN || !connectionId) {
      showStatusMessage('Not connected to server. Please try again.', 'error');
      return;
    }
    
    // Send login request
    socket.send(JSON.stringify({
      type: 'login',
      email: email,
      password: password
    }));
  });
  
  // Register form submission
  $('#register-form').on('submit', function(e) {
    e.preventDefault();
    
    const email = $('#register-email').val();
    const password = $('#register-password').val();
    const confirm = $('#register-confirm').val();
    
    if (!email || !password || !confirm) {
      showStatusMessage('Please fill in all fields', 'error');
      return;
    }
    
    if (password !== confirm) {
      showStatusMessage('Passwords do not match', 'error');
      return;
    }
    
    if (!socket || socket.readyState !== WebSocket.OPEN || !connectionId) {
      showStatusMessage('Not connected to server. Please try again.', 'error');
      return;
    }
    
    // Send register request
    socket.send(JSON.stringify({
      type: 'register',
      email: email,
      password: password
    }));
  });
  
  // Helper function to show status messages
  function showStatusMessage(message, type) {
    const statusElement = $('#status-message');
    statusElement.removeClass('error success').addClass(type).text(message).show();
  }
});
