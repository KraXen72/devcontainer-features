
# GitHub Copilot CLI (copilot-cli)

Installs GitHub Copilot CLI from the official release installer

## Example Usage

```json
"features": {
    "ghcr.io/kraxen72/devcontainer-features/copilot-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Copilot CLI version to install. Use 'latest', 'prerelease', or a specific version like '1.2.3' or 'v1.2.3'. | string | latest |
| autoUpdate | Run 'copilot update' on each container start. Only useful when version is 'latest' or 'prerelease'. | boolean | false |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
