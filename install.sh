#!/bin/bash

INSTALL_DIR="json-server-auth-token"
INSTALL_ABS_PATH="$PWD/$INSTALL_DIR"

# Function to check if jq is installed
check_jq() {
  if ! [ -x "$(command -v jq)" ]; then
    echo "jq is not installed. Installing jq..."
    if [ "$(uname)" == "Darwin" ]; then
      # Install jq on macOS using Homebrew
      brew install jq
    elif [ "$(uname)" == "Linux" ]; then
      # Install jq on Linux
      sudo apt-get update && sudo apt-get install -y jq
    else
      echo "Unsupported OS. Please install jq manually."
      exit 1
    fi
  else
    echo "jq is already installed!"
  fi
}

# Function to check if Node.js is installed
check_node() {
  if ! [ -x "$(command -v node)" ]; then
    echo "Node.js is not installed. Installing Node.js..."
    if [ "$(uname)" == "Darwin" ]; then
      # Install Node.js on macOS using Homebrew
      brew install node || curl -fsSL https://install-node.vercel.app/lts | bash
    elif [ "$(uname)" == "Linux" ]; then
      # Install Node.js on Linux
      curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      sudo apt-get install -y nodejs
    else
      echo "Unsupported OS. Please install Node.js manually."
      exit 1
    fi
  else
    echo "Node.js is already installed!"
  fi
}

# Function to check if npm is installed
check_npm() {
  if ! [ -x "$(command -v npm)" ]; then
    echo "npm is not installed. Please install npm before proceeding."
    exit 1
  else
    echo "npm is installed!"
  fi
  # npm init -y
  # npm install -g json-server@0.17.4
  # npm install -g jsonwebtoken
  # npm install json-server@0.17.4
  # npm install jsonwebtoken
}

# Function to create configuration.json if missing
check_config() {
  CONFIG_FILE="configuration.json"

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating default $CONFIG_FILE..."
    cat <<'EOL' > $CONFIG_FILE
{
  "secretKey": "secret",
  "tokenExpiration": "1h",
  "port": 3000
}
EOL
    echo "$CONFIG_FILE created with default values."
  fi

  # Validate required keys
  REQUIRED_KEYS=("secretKey" "tokenExpiration" "port")
  for key in "${REQUIRED_KEYS[@]}"; do
    value=$(jq -r ".${key}" "$CONFIG_FILE")
    if [ "$value" == "null" ] || [ -z "$value" ]; then
      echo "Error: Missing required key '$key' in $CONFIG_FILE."
      exit 1
    fi
  done

  echo "$CONFIG_FILE is valid!"
}

mkdir $INSTALL_DIR
cd $INSTALL_DIR

# Check for prerequisites
check_jq
check_node
check_npm
check_config

# Initialize npm if package.json does not exist
if [ ! -f "package.json" ]; then
  npm init -y > '/dev/null' 2>&1
fi

# Install dependencies
echo "Installing dependencies..."
npm install fs path json-server@0.17.4 express jsonwebtoken body-parser > '/dev/null' 2>&1

# Create necessary files if they do not exist
if [ ! -f "db.json" ]; then
  cat <<'EOL' > db.json
{
  "posts": [
    { "id": 1, "title": "Hello World", "author": "Mit" },
    { "id": 2, "title": "Demo Post", "author": "Jane Doe" }
  ]
}
EOL
  echo "Created db.json"
fi

if [ ! -f "auth.json" ]; then
  cat <<'EOL' > auth.json
{
  "users": [
    { "id": 1, "username": "admin", "password": "password" }
  ]
}
EOL
  echo "Created auth.json"
fi

if [ ! -f "server.js" ]; then
  cat <<'EOL' > server.js
const jsonServer = require('json-server');
const express = require('express');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const path = require('path');
const fs = require('fs');

// Load configuration relative to server.js
const configPath = path.join(__dirname, 'configuration.json');
const config = JSON.parse(fs.readFileSync(configPath));

const app = express();
const dbPath = path.join(__dirname, 'db.json');
const router = jsonServer.router(dbPath);
const authPath = path.join(__dirname, 'auth.json');
const auth = jsonServer.router(authPath);
const middlewares = jsonServer.defaults();

// Middleware
app.use(bodyParser.json());
app.use(middlewares);

// Secret key and settings from configuration
const SECRET_KEY = config.secretKey;
const expiresIn = config.tokenExpiration;
const PORT = config.port || 3000;

// Generate JWT Token
const createToken = (payload) => {
  return jwt.sign(payload, SECRET_KEY, { expiresIn });
};

// Verify JWT Token
const verifyToken = (token) => {
  return jwt.verify(token, SECRET_KEY, (err, decoded) =>
    err ? null : decoded
  );
};

// Authentication Middleware
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ message: 'No token provided' });

  const token = authHeader.split(' ')[1];
  const decoded = verifyToken(token);

  if (!decoded) return res.status(401).json({ message: 'Invalid or expired token' });

  req.user = decoded; // Attach decoded user to the request
  next();
};

// Login Route
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Replace with your user authentication logic
  const user = auth.db.get('users').find({ username, password }).value();

  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }

  const token = createToken({ id: user.id, username: user.username });
  return res.json({ token });
});

// Protected Routes (Apply authMiddleware)
app.use('/posts', authMiddleware);

// Serve JSON Server routes
app.use(router);

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});
EOL
  echo "Created server.js"
fi

# Instructions for starting the server
echo "Setup complete!"
echo ""
echo -e "\033[1;32mTo start the server, run: \033[1;36mnode $INSTALL_DIR/server.js\033[0m"
echo ""
