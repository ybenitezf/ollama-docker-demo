## ADDED Requirements

### Requirement: Push to Docker Hub on main branch
When a commit is pushed to the main branch, the GitHub Actions workflow SHALL authenticate to Docker Hub using the configured secrets and push the built image to `ybenitezf/ollama-docker-demo`.

#### Scenario: Successful push on main branch push
- **WHEN** a commit is pushed to the main branch
- **THEN** the workflow authenticates to Docker Hub using `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets
- **AND** the image is pushed with both `:latest` and `:<sha>` tags

#### Scenario: No push on pull request
- **WHEN** a pull request is opened or updated
- **THEN** the workflow builds the image to verify it compiles
- **AND** the image is NOT pushed to Docker Hub

### Requirement: Image tagging
The Docker image SHALL be tagged with both `:latest` and the full Git SHA for traceability.

#### Scenario: Latest tag always points to newest build
- **WHEN** a successful build completes
- **THEN** the image is pushed with the `:latest` tag

#### Scenario: SHA tag provides traceability
- **WHEN** a successful build completes
- **THEN** the image is pushed with the `:<sha>` tag where sha is `github.sha`
