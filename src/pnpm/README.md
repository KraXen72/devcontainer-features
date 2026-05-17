
# pnpm (via npm) (pnpm)

Installs pnpm via npm. Based on devcontainers-extra/features/pnpm. This feature does not install nodejs or npm.

## Example Usage

```json
"features": {
    "ghcr.io/kraxen72/devcontainer-features/pnpm:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version/range of pnpm to install (for example, '10' to stay on the latest pnpm v10). | string | latest |
| configureMinimumReleaseAge | Run 'pnpm config set minimumReleaseAge --global'. No-op on v11+ which already defaults to 1440, but useful for v10. | boolean | true |
| minimumReleaseAge | Value for 'pnpm config set minimumReleaseAge <value> --global'. | string | 1440 |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
