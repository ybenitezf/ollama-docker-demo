## ADDED Requirements

### Requirement: Bearer token validation
The system SHALL validate the bearer token in the Authorization header before forwarding requests to the Ollama API.

#### Scenario: Valid bearer token
- **WHEN** a request includes an Authorization header with value `Bearer <valid_token>` where `<valid_token>` matches the PRIVATE_KEY environment variable
- **THEN** the request SHALL be forwarded to Ollama and the response returned to the client

#### Scenario: Missing authorization header
- **WHEN** a request does not include an Authorization header
- **THEN** the system SHALL return HTTP 401 with body "Unauthorized"

#### Scenario: Invalid bearer token
- **WHEN** a request includes an Authorization header with value that does not match `Bearer <valid_token>`
- **THEN** the system SHALL return HTTP 401 with body "Unauthorized"

#### Scenario: Malformed authorization header
- **WHEN** a request includes an Authorization header with a non-Bearer format (e.g., "Basic xyz")
- **THEN** the system SHALL return HTTP 401 with body "Unauthorized"

### Requirement: PRIVATE_KEY environment variable
The system SHALL read the bearer token from the PRIVATE_KEY environment variable at container startup.

#### Scenario: PRIVATE_KEY is set
- **WHEN** the PRIVATE_KEY environment variable is set when the container starts
- **THEN** the nginx proxy SHALL use this value for bearer token validation

#### Scenario: PRIVATE_KEY is not set
- **WHEN** the PRIVATE_KEY environment variable is not set when the container starts
- **THEN** the nginx proxy SHALL fail to validate any tokens (all requests return 401)
- **AND** the prepare.sh script SHALL log a warning about the missing key

### Implementation Note: envsubst usage
When using envsubst to substitute the PRIVATE_KEY variable, ONLY the PRIVATE_KEY variable should be specified to prevent nginx variables (e.g., $scheme, $http_upgrade, $http_authorization) from being incorrectly substituted.

```bash
# CORRECT - only specifies PRIVATE_KEY
envsubst '${PRIVATE_KEY}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# INCORRECT - substitutes all $ variables, breaking nginx config
envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
```

### Requirement: Proxy headers
The system SHALL pass appropriate proxy headers to Ollama while hiding the client's true origin.

- **The Host header SHALL be set to "localhost"**
- **The X-Real-IP header SHALL be set to "127.0.0.1"**
- **The X-Forwarded-For header SHALL be set to "127.0.0.1"**
- **The X-Forwarded-Proto header SHALL be set to the request scheme**

#### Scenario: Request forwarded with authentication
- **WHEN** a valid bearer token is provided and the request is forwarded to Ollama
- **THEN** Ollama SHALL receive requests with Host: localhost, X-Real-IP: 127.0.0.1

### Requirement: WebSocket support
The system SHALL support WebSocket connections for streaming responses.

- **The Upgrade header SHALL be passed through to Ollama**
- **The Connection header SHALL be set to 'upgrade'**
- **The proxy_http_version SHALL be set to 1.1**

#### Scenario: Streaming chat request
- **WHEN** a client makes a streaming chat request with valid bearer token
- **THEN** the WebSocket headers SHALL be forwarded and streaming SHALL work correctly
