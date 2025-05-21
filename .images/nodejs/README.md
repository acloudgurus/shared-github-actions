---
prev:
    text: Maven Image
    link: '../maven/'
next:
    text: Build
    link: ../../build/
---

# Nodejs Image

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
      image: ghcr.io/zilvertonz/shared-github-actions:v1-nodejs
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
- [nvm](https://github.com/nvm-sh/nvm)

##### `nvm` Cheatsheet

Install nodejs version 20
```bash
node --version # errors no, node is not installed
nvm install 20
node --version # v20.18.0 or similar
``` 

For more examples, look at the docs: [nvm-sh/nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#usage)
