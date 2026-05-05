
# OpenSSH Server for Zed (ssh-zed)

Configures sshd on port 2222 for Zed remote development. If dropbear is in the base image, the feature will be faster due to not having to install it on its own.

## Example Usage

```json
"features": {
    "ghcr.io/kraxen72/devcontainer-features/ssh-zed:2": {}
}
```





---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
