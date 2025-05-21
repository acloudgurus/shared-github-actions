---
prev:
    text: Glue 4.0 Image
    link: '../glue4/'
next:
    text: Maven
    link: '../maven/'
---

# Base Image

This image is based from `amazonlinux:2023` and meant for applications deployed 
in AWS.

See base [deps](#always-installed)

### Usage
To use this image, include the following at the job level:

```yaml
# example workflow, ie .github/workflows/test.yaml
jobs:
  CICD:
    name: CICD
    runs-on: MA-Analytics-Runner
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-k8s-1.31.0
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4
```

### Dependencies

> [!IMPORTANT]
> Dependencies differ from the default ubuntu image

See all [base dependencies](../base/#always-installed) which are also installed 
on this image.

#### `kubectl` Versions

> [!NOTE]
> To add more versions, add to the version matrix in `.github/workflows/feature-images.yaml` 
> and `.github/workflows/tag-and-release.yaml`

- 1.26.0
- 1.30.0
- 1.31.0

#### Always Installed
- kubectl

