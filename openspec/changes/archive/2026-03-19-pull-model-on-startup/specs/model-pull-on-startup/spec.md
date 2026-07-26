## ADDED Requirements

### Requirement: MODEL env var triggers model pull on startup

The system SHALL attempt to pull the Ollama model specified by the `MODEL` environment variable when the container starts.

#### Scenario: MODEL is set
- **WHEN** the container starts with `MODEL` environment variable set to a valid Ollama model (e.g., `llama3:8b`)
- **THEN** the system SHALL wait for Ollama to be ready, then execute `ollama pull $MODEL`
- **AND** the system SHALL log progress during the pull

#### Scenario: MODEL is not set
- **WHEN** the container starts with `MODEL` environment variable unset or empty
- **THEN** the system SHALL log a warning message
- **AND** the system SHALL proceed with startup without attempting a pull

### Requirement: Pull waits for Ollama readiness

The system SHALL wait for Ollama to be ready before executing the pull command.

#### Scenario: Ollama takes time to start
- **WHEN** the pull process begins before Ollama is ready
- **THEN** the system SHALL poll `ollama list` until it succeeds
- **AND** the system SHALL log each wait iteration

### Requirement: Pull failures retry up to 3 times

The system SHALL retry a failed pull up to 3 times.

#### Scenario: Network failure during pull
- **WHEN** `ollama pull` fails due to a transient error
- **THEN** the system SHALL retry the pull
- **AND** the system SHALL retry up to 3 times total before giving up

#### Scenario: Pull succeeds
- **WHEN** `ollama pull` completes successfully
- **THEN** the system SHALL exit with code 0
- **AND** the system SHALL not restart the pull process
