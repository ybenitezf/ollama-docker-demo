## ADDED Requirements

### Requirement: Nginx listens on port 8080
The nginx reverse proxy SHALL listen on port 8080 instead of port 80.

#### Scenario: Nginx configured for port 8080
- **WHEN** the Docker container is running
- **THEN** nginx listens on port 8080

### Requirement: Docker EXPOSE reflects port 8080
The Dockerfile SHALL expose port 8080 to indicate the container's listening port.

#### Scenario: Dockerfile EXPOSE updated
- **WHEN** the Dockerfile is built
- **THEN** EXPOSE 8080 is present in the image

### Requirement: Documentation updated for port 8080
All documentation SHALL reflect the use of port 8080 for the nginx service.

#### Scenario: Documentation reflects new port
- **WHEN** users consult the documentation
- **THEN** they see port 8080 as the correct port to access the service
