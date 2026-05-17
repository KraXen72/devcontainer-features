
# OpenAI Codex CLI (codex-cli)

Installs OpenAI Codex CLI globally with pnpm.
Codex state is stored in a persistent container-side ~/.codex volume.
When this feature is used through dcman, dcman copies host ~/.codex/auth.json into that volume before launching Codex. This lets Codex reuse a host ChatGPT/device-login session without requiring an API key, while avoiding a long-lived host ~/.codex bind mount inside the sandboxed container.

## Example Usage

```json
"features": {
    "ghcr.io/kraxen72/devcontainer-features/pnpm:1": {},
    "ghcr.io/kraxen72/devcontainer-features/codex-cli:1": {
        "version": "latest",
        "autoUpdate": true
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Codex CLI npm version, dist-tag, or range to install for @openai/codex, for example 'latest', 'alpha', or '0.130.0'. | string | latest |
| autoUpdate | Run 'pnpm add --global @openai/codex@<version>' on each container start when version is not pinned to an exact version. | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
