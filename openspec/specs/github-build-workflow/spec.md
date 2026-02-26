## ADDED Requirements

### Note
- setup-buildx-action uses v3 (v4 does not exist)

### Requirement: GitHub Actions workflow builds Docker image
The GitHub Actions workflow SHALL build the Docker image defined in Dockerfile to verify it builds successfully without errors.

#### Scenario: Workflow runs on push to main
- **WHEN** code is pushed to the main branch
- **THEN** GitHub Actions workflow triggers and builds the Docker image using docker/build-push-action with load:true

#### Scenario: Workflow runs on pull request
- **WHEN** a pull request is opened or updated against main branch
- **THEN** GitHub Actions workflow triggers and builds the Docker image

#### Scenario: Build fails shows error
- **WHEN** the Dockerfile has an error preventing successful build
- **THEN** workflow fails and shows error message indicating what went wrong

#### Scenario: Build success shows completion
- **WHEN** the Dockerfile builds successfully
- **THEN** workflow completes with success status
