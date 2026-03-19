## Why

The nginx default `client_max_body_size` of 1MB is insufficient for vision model requests that include base64-encoded images. A single request with multiple images easily exceeds this limit, causing 413 "Request Entity Too Large" errors.

## What Changes

- Add `client_max_body_size 100M;` directive to the nginx `http` block in `nginx.conf.template`

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

_(none)_

## Impact

- **File modified**: `nginx.conf.template`
- **No breaking changes**: This is a permissive limit increase
- **No new dependencies**
