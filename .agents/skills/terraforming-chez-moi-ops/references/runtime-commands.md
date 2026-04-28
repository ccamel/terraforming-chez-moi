# Runtime Commands

Use these as command patterns. Replace placeholders locally; do not echo secrets.

## SSH

Prefer deployment variables when available:

```bash
ssh -p "${TF_VAR_deploy_ssh_port:-22}" \
  -i "$TF_VAR_deploy_ssh_private_key_path" \
  "${TF_VAR_deploy_ssh_user:-$TF_VAR_dsm_user}@${TF_VAR_deploy_ssh_host:-$TF_VAR_dsm_host}"
```

For one-shot remote commands:

```bash
ssh -p "${TF_VAR_deploy_ssh_port:-22}" \
  -i "$TF_VAR_deploy_ssh_private_key_path" \
  "${TF_VAR_deploy_ssh_user:-$TF_VAR_dsm_user}@${TF_VAR_deploy_ssh_host:-$TF_VAR_dsm_host}" \
  'docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
```

## Stack Location

Find the remote directory in the Terraform module call:

```bash
rg -n 'module "<project>"|remote_dir|stack_name|project_name' <project>.tf
```

Most stacks use a DSM folder parent as `remote_dir`, for example:

```hcl
remote_dir = dirname(synology_filestation_folder.<name>.real_path)
```

## Read-Only Docker Checks

List containers:

```bash
docker ps -a --filter 'label=com.docker.compose.project=<project>' \
  --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
```

Check Compose status from the remote stack directory:

```bash
cd '<remote_dir>' && docker compose -p '<project>' ps
```

Read recent logs without dumping too much:

```bash
cd '<remote_dir>' && docker compose -p '<project>' logs --tail=200 --timestamps
```

Inspect health and restart count:

```bash
docker inspect '<container>' \
  --format 'status={{.State.Status}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}} restarts={{.RestartCount}} started={{.State.StartedAt}} finished={{.State.FinishedAt}}'
```

Inspect image, mounts, and networks:

```bash
docker inspect '<container>' \
  --format 'image={{.Config.Image}} mounts={{json .Mounts}} networks={{json .NetworkSettings.Networks}}'
```

Check external networks:

```bash
docker network ls
docker network inspect edge infra
```

## Bind Mounts And Permissions

Check stack files without printing `.env` values:

```bash
cd '<remote_dir>' && ls -la && test -f .env && stat .env || true
```

Check persistent folders:

```bash
find '<remote_dir>' -maxdepth 2 -type d -print -exec stat -c '%U:%G %a %n' {} \;
```

On Synology, GNU `stat -c` may be unavailable. Use:

```bash
find '<remote_dir>' -maxdepth 2 -type d -print -exec ls -ld {} \;
```

## Controlled Runtime Actions

Only run these when the user explicitly asks for runtime action:

```bash
cd '<remote_dir>' && docker compose -p '<project>' restart '<service>'
cd '<remote_dir>' && docker compose -p '<project>' up -d
cd '<remote_dir>' && docker compose -p '<project>' pull
```

Avoid `docker compose down`, `docker rm`, volume removal, network removal, permission changes, and manual remote file edits unless the user explicitly requests them and understands the Terraform drift risk.
