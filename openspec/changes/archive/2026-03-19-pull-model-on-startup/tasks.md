## 1. New files

- [x] 1.1 Create `pull-wrapper.sh` with polling loop and model pull
- [x] 1.2 Add execute permission to `pull-wrapper.sh`

## 2. Dockerfile updates

- [x] 2.1 Add `COPY pull-wrapper.sh /pull-wrapper.sh` instruction
- [x] 2.2 Validate Dockerfile with `hadolint`

## 3. supervisord updates

- [x] 3.1 Add `[program:pull]` section with `pull-wrapper.sh` command
- [x] 3.2 Set `autorestart=true` and `startretries=3`
- [x] 3.3 Set `exitcodes=0` so supervisord knows when pull succeeded

## 4. prepare.sh updates

- [x] 4.1 Add warning when `MODEL` env var is not set
- [x] 4.2 Validate with `shellcheck`

## 5. Validation

- [x] 5.1 Run lint: `shellcheck *.sh && hadolint Dockerfile && nginx -t -c nginx.conf.template`
- [x] 5.2 Review all changed files for correctness
