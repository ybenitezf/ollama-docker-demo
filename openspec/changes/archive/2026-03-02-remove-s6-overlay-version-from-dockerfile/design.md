## Context

The Dockerfile at the root of the repository contains an unused ARG declaration for `S6_OVERLAY_VERSION=3.2.2.0` on line 3. This variable was previously used to download and install the S6 overlay init system, but that functionality was removed in a prior change. The variable declaration remains but is no longer referenced anywhere in the Dockerfile.

## Goals / Non-Goals

**Goals:**
- Remove the unused `ARG S6_OVERLAY_VERSION=3.2.2.0` line from the Dockerfile

**Non-Goals:**
- No refactoring of other Dockerfile sections
- No changes to the build process or container functionality
- No changes to other configuration files

## Decisions

1. **Simple line removal**: The change is straightforward - just delete line 3 from the Dockerfile. No additional refactoring is needed since this is a minor cleanup task.

## Risks / Trade-offs

- **Risk**: None. This is a safe, isolated change that only removes an unused variable.
- **Trade-off**: None. There is no downside to removing unused code.
