
# pnpm (via npm) (pnpm)

Installs pnpm via npm. Based on devcontainers-extra/features/pnpm .This feature does not install nodejs or npm.

## Example Usage

```json
"features": {
    "ghcr.io/kraxen72/devcontainer-features/pnpm:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of pnpm to install. | string | latest |
| configureMinimumReleaseAge | Run 'pnpm config set minimumReleaseAge 1440 --global'. | boolean | true |
| minimumReleaseAge | Value for 'pnpm config set minimumReleaseAge <value> --global'. | string | 1440 |
| storeDir | Directory where the pnpm store is exposed in the container. | string | ~/.pnpm-store |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
