## 1. Prepare Template Files

- [x] 1.1 Rename nginx.conf to nginx.conf.template
- [x] 1.2 Add ${PRIVATE_KEY} placeholder to nginx.conf.template bearer token validation

## 2. Create Entrypoint Script

- [x] 2.1 Create prepare.sh script
- [x] 2.2 Add envsubst command to substitute PRIVATE_KEY in nginx template
- [x] 2.3 Add validation to check PRIVATE_KEY is set
- [x] 2.4 Make script executable and exec to supervisord

## 3. Update Dockerfile

- [x] 3.1 Install gettext-base package in Dockerfile
- [x] 3.2 Copy nginx.conf.template to /etc/nginx/nginx.conf
- [x] 3.3 Copy prepare.sh to /prepare.sh
- [x] 3.4 Set ENTRYPOINT to /prepare.sh

## Configuration

- [x] 4.1 Run hadolint on updated Dockerfile
- [x] 4.2 Run nginx -t on nginx.conf.template (after envsubst)
- [x] 4.3 Verify shellcheck passes on prepare.sh

## 5. Documentation

- [x] 5.1 Document PRIVATE_KEY environment variable requirement in deployment notes
- [x] 5.2 Update README with authentication instructions

## 6. Post-Deployment Fixes

- [x] 6.1 Fix envsubst to only substitute PRIVATE_KEY variable (not nginx variables like $scheme, $http_upgrade)
