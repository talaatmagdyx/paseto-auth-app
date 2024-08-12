# PASETO Auth App

This is a Ruby on Rails application that uses PASETO (Platform-Agnostic Security Tokens) for secure token-based authentication. The app demonstrates how to create, validate, and use PASETO tokens for user authentication.

## Features

- **User Sign-Up**: Create a new user with a name, email, and password.
- **User Login**: Authenticate a user and return a PASETO token for subsequent requests.
- **Protected Routes**: Access routes that require a valid PASETO token.

## Requirements

- Ruby 3.3.4
- Rails 7.2.0
- `ruby-paseto` gem

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/talaatmagdyx/paseto-auth-app.git
cd paseto-auth-app
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Set Up the Database

```bash
rails db:create
rails db:migrate
```

### 4. Generate a Symmetric Key

PASETO tokens require a symmetric key for encryption and decryption. This key must be 32 bytes long.

Generate a 32-byte key and encode it in Base64:

```ruby
require 'securerandom'
require 'base64'

key = SecureRandom.bytes(32)
base64_key = Base64.strict_encode64(key)
puts base64_key
```

### 5. Store the Key in Rails Credentials

Edit your Rails credentials to store the generated key:

```bash
rails credentials:edit
```

Add the following:

```yaml
paseto:
  secret_key: "your_base64_encoded_key_here"
```

### 6. Start the Rails Server

```bash
rails server
```

## API Endpoints

### 1. Sign Up a New User

- **URL**: `/users`
- **Method**: `POST`
- **Request Body**:

```json
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

- **Response**: `201 Created` if successful

### 2. Log In

- **URL**: `/login`
- **Method**: `POST`
- **Request Body**:

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

- **Response**: `200 OK` with a PASETO token in the response body:

```json
{
  "token": "v4.local.your_pasetoken_here"
}
```

### 3. Access Protected Route

- **URL**: `/protected`
- **Method**: `GET`
- **Headers**:
    - `Authorization: Bearer your_pasetoken_here`

- **Response**: `200 OK` if the token is valid, otherwise `401 Unauthorized`.

## Example Postman Collection

You can use the following Postman collection to test the API endpoints:

```json
{
	"info": {
		"_postman_id": "1ff676d8-9896-4368-abde-008b548b4554",
		"name": "paseto",
		"schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
	},
	"item": [
		{
			"name": "Sign Up a New User",
			"request": {
				"method": "POST",
				"header": [],
				"body": {
					"mode": "raw",
					"raw": "{\n  \"user\": {\n    \"name\": \"John Doe\",\n    \"email\": \"john@example.com\",\n    \"password\": \"password123\",\n    \"password_confirmation\": \"password123\"\n  }\n}",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "http://localhost:3000/users",
					"protocol": "http",
					"host": [
						"localhost"
					],
					"port": "3000",
					"path": [
						"users"
					]
				}
			},
			"response": []
		},
		{
			"name": "Log In",
			"request": {
				"method": "POST",
				"header": [],
				"body": {
					"mode": "raw",
					"raw": "{\n  \"email\": \"john@example.com\",\n  \"password\": \"password123\"\n}",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "http://localhost:3000/login",
					"protocol": "http",
					"host": [
						"localhost"
					],
					"port": "3000",
					"path": [
						"login"
					]
				}
			},
			"response": []
		},
		{
			"name": "Access Protected Route",
			"request": {
				"method": "GET",
				"header": [
					{
						"key": "Authorization",
						"value": "Bearer your_pasetoken_here",
						"type": "default"
					}
				],
				"url": {
					"raw": "http://localhost:3000/protected",
					"protocol": "http",
					"host": [
						"localhost"
					],
					"port": "3000",
					"path": [
						"protected"
					]
				}
			},
			"response": []
		}
	]
}
```

### How to Import into Postman

1. Open Postman.
2. Click on "Import" in the top left.
3. Choose "Raw Text" and paste the JSON provided above.
4. Click "Continue" and then "Import".

## Authentication Workflow

1. **Sign Up**: Users first sign up to create an account.
2. **Log In**: Users log in with their credentials to receive a PASETO token.
3. **Protected Routes**: Users can access protected routes by including the token in the `Authorization` header of their requests.

## Security Considerations

- The PASETO token is symmetrically encrypted, which ensures confidentiality and authenticity.
- Ensure that the `secret_key` is stored securely in Rails credentials and is not exposed in your source code.

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with any changes or improvements.

## Contact

For any questions or support, please open an issue on the repository.
