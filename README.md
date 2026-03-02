# Ollama in runpod

Docker image for using ollama + nginx in an runpod pod

## Authentication

This image requires bearer token authentication. All requests must include a valid Authorization header.

### Required Environment Variable

Set the `PRIVATE_KEY` environment variable in your RunPod pod configuration with your desired bearer token.

### Using the API

Include the Authorization header in your requests:

```bash
curl -H "Authorization: Bearer YOUR_PRIVATE_KEY" http://your-pod-url:8080/api/generate
```