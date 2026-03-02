## Why

The Dockerfile currently defines an ARG `S6_OVERLAY_VERSION=3.2.2.0` that is no longer used in the build process. The S6 overlay installation was removed in a previous change, but the unused variable declaration remains. This creates confusion and unnecessary complexity in the Dockerfile.

## What Changes

- Remove the `ARG S6_OVERLAY_VERSION=3.2.2.0` line from the Dockerfile (line 3)

## Capabilities

### New Capabilities
(None - this is a cleanup change with no new functionality)

### Modified Capabilities
(None - no existing capability requirements are changing)

## Impact

- **Affected file**: `Dockerfile`
- **No breaking changes**: This only removes an unused variable declaration
- **No impact on functionality**: The container builds and runs identically before and after this change
