
# GitHub Copilot CLI (copilot-cli)

Installs GitHub Copilot CLI from the official release installer.
Copilot CLI state is shared across containers via a named Docker volume (copilot-shared).
This feature never bind-mounts host ~/.copilot and does not create or copy settings.json; authenticate with COPILOT_GITHUB_TOKEN or the CLI's normal auth flow inside the shared volume.

## Example Usage

```json
"features": {
    "ghcr.io/kraxen72/devcontainer-features/copilot-cli:2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Copilot CLI version to install. Use 'latest', 'prerelease', or a specific version like '1.2.3' or 'v1.2.3'. | string | latest |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
