---
prev:
    text: k8s
    link: '../k8s/'
next:
    text: Nodejs Image
    link: '../nodejs/'
---

# Maven Image - Linux Image

This image is based from `amazonlinux:2023` and meant for applications deployed 
in AWS.

### Usage
To use this image, include the following at the job level:


```yaml
# example workflow, ie .github/workflows/test.yaml
jobs:
  CICD:
    name: CICD
    runs-on: MA-Analytics-Runner
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-maven
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

#### Always Installed
- [maven](https://maven.apache.org/)

