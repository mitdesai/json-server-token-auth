# JSON Server with Token-Based Authentication

This project provides a setup script (`install.sh`) to install and configure a JSON server with token-based authentication. It is inspired by and almost entirely based on [json-server](https://github.com/typicode/json-server) and [jsonwebtoken](https://github.com/auth0/node-jsonwebtoken).

While `json-server` is excellent for quickly mocking REST APIs, it does not include built-in support for authentication or protected routes. The `json-server-auth-token` project extends the functionality of `json-server` by adding:
- **Token-based authentication** using [JSON Web Tokens (JWT)](https://github.com/auth0/node-jsonwebtoken).
- **Protected routes** that require a valid token for access.
- A simple mechanism for managing users and securing endpoints.

This project is perfect for prototyping or testing applications that require authentication and authorization flow before accessing the endpoints.

---

## Installation

### Prerequisites
Ensure you have the following tools installed:
- **Node.js**: For running the server.
- **npm**: For managing dependencies.
- **jq**: A lightweight JSON processor (the script installs it if missing).

### Installation Steps
Run the following command in the directory where you want to install the JSON server:
```bash
curl -s https://raw.githubusercontent.com/mitdesai/json-server-token-auth/refs/heads/main/install.sh | bash
```

> **Note**: The script creates a directory named `json-server-auth-token` in the current working directory and installs all necessary files and dependencies there.

---

## Files Created by the Script
1. **`configuration.json`**: Contains server configurations such as:
   - `secretKey`: The JWT secret key.
   - `tokenExpiration`: Token expiry duration.
   - `port`: The server's listening port.

   Example:
   ```json
   {
     "secretKey": "your-secret-key",
     "tokenExpiration": "1h",
     "port": 3000
   }
   ```

2. **`db.json`**: The mock database for the API with a `posts` collection.
   Example:
   ```json
   {
     "posts": [
       { "id": 1, "title": "Hello World", "author": "Mit" },
       { "id": 2, "title": "Demo Post", "author": "Jane Doe" }
     ]
   }
   ```

3. **`auth.json`**: Contains user authentication data.
   Example:
   ```json
   {
     "users": [
       { "id": 1, "username": "admin", "password": "password" }
     ]
   }
   ```

4. **`server.js`**: The server script for handling authentication and serving API routes.

---

## Starting the Server

1. Navigate to the created directory:
   ```bash
   cd json-server-auth-token
   ```

2. Start the server:
   ```bash
   node server.js
   ```

3. The server will run on the port defined in `configuration.json` (default: `3000`):
   ```
   Server is running at http://localhost:3000
   ```

---

## Usage

### 1. Login to Get a Token
Use the `/login` endpoint to obtain a JWT token. Provide the `username` and `password` from `auth.json`.

#### Request:
```bash
curl -X POST http://localhost:3000/login \
-H "Content-Type: application/json" \
-d '{"username": "admin", "password": "password"}'
```

#### Response:
```json
{
  "token": "your-jwt-token"
}
```

---

### 2. Access Protected Endpoints
Use the token from the login response to access protected routes like `/posts`.

#### Request:
```bash
curl -X GET http://localhost:3000/posts \
-H "Authorization: Bearer your-jwt-token"
```

#### Response:
```json
[
  { "id": 1, "title": "Hello World", "author": "Mit" },
  { "id": 2, "title": "Demo Post", "author": "Jane Doe" }
]
```

---

### 3. Perform CRUD Operations
- **Create a New Post**:
  ```bash
  curl -X POST http://localhost:3000/posts \
  -H "Authorization: Bearer your-jwt-token" \
  -H "Content-Type: application/json" \
  -d '{"id": 3, "title": "New Post", "author": "John Doe"}'
  ```

- **Update a Post**:
  ```bash
  curl -X PUT http://localhost:3000/posts/3 \
  -H "Authorization: Bearer your-jwt-token" \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Post", "author": "John Doe"}'
  ```

- **Delete a Post**:
  ```bash
  curl -X DELETE http://localhost:3000/posts/3 \
  -H "Authorization: Bearer your-jwt-token"
  ```

---

## Notes
1. Update the `secretKey` in `configuration.json` before starting the server to ensure secure authentication.
2. You can customize the server's behavior by modifying `configuration.json` and the `server.js` script.

---

## Acknowledgments
This project is inspired by the [json-server](https://github.com/typicode/json-server) by Typicode.

---

## License
This project is licensed under the MIT License.
