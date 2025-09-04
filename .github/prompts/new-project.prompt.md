---
mode: agent
---

1. **Create project files:**

   - Create `<projectname>.tf` for the main project configuration
   - Create `<projectname>.variables.tf` if variables are needed

2. **Set up persistence (if required):**

   - Use `synology_filestation_folder` resource to create folders
   - Follow the path pattern: `${var.dsm_volume_projects}/<projectname>/folder-name`

3. **Add permfix service (only when needed):**

   - Apply a `permfix` service only when the main container requires specific ownership/permissions (e.g. Bitnami Postgres with uid 1001)
   - Run once as root
   - Set folder ownership to required uid:gid
   - Set permissions to `700`

4. **Define the main service:**

   - Use a clear and consistent name
   - Configure bind mounts to DSM folders for persistence
   - Add a healthcheck when appropriate (databases, stateful services)
   - Expose ports via variables (never hard-coded)
   - Add dependency on `permfix` completion if applicable
   - Select production-grade container images:
     - Prefer official, well-maintained images from reputable registries.
     - Pin a specific, stable tag; prefer digest pinning when possible.
     - Prefer smaller, minimal images that run as non-root when possible and have sensible production defaults.

5. **Configure database (if needed):**

   - Use the existing PostgreSQL service if compatible
   - Otherwise configure the database (e.g. MongoDB) in the `infra-db` project

6. **Validate and test:**
   - Run `just validate` to check syntax
   - Run `just fmt` to format code
