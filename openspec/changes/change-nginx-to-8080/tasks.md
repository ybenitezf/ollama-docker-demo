## 1. Update nginx Configuration

- [x] 1.1 Change nginx listen port from 80 to 8080 in nginx.conf
- [x] 1.2 Restructure nginx.conf to be a complete standalone config

## 2. Update Dockerfile

- [x] 2.1 Change EXPOSE directive from 80 to 8080 in Dockerfile
- [x] 2.2 Copy nginx.conf to /etc/nginx/nginx.conf instead of sites-available

## 3. Update Documentation

- [x] 3.1 Update AGENTS.md port references from 8080:80 to 8080:8080
