---
prev:
    text: Base Image
    link: '../base/'
next:
    text: k8s
    link: '../k8s/'
---

# Glue 4.0 Image - Linux Image

This image is based from `ghcr.io/zilvertonz/shared-github-actions:v1-base` and meant for applications deployed 
in AWS that rely on Glue scripts.


### Usage
To use this image, include the following at the job level:


```yaml
# example workflow, ie .github/workflows/test.yaml
jobs:
  CICD:
    name: CICD
    runs-on: MA-Analytics-Runner
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-glue4
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup uv python 3.10
        id: py_setup
        run: |
          uv python pin 3.10
```

If you would like to install the glue package, a whl distribution is created and located in /usr/local/bin/aws-glue-libs/. To install, include the [shared actions python install step](../../install/python/README.md) to the job:
```yaml
# ...above example
      - name: Install Dependencies
        id: install_deps
        uses: zilvertonz/shared-github-actions/install/python@v1
        with:
          environment_usage: ${{ env.SHELL_ENVIRONMENT }}
          toml_parent_dir: module/aws/glue_code/glue_job
          additional_dependencies: /usr/local/bin/aws-glue-libs/*.whl
```

### Dependencies

> [!IMPORTANT]
> Dependencies differ from the default ubuntu image

See all [base dependencies](../base/README.md#always-installed) which are also installed 
on this image.

#### Always Installed
- [maven-local-amazon-corretto8](https://hub.docker.com/layers/library/maven/3.8.1-amazoncorretto-8/images/sha256-e47831cecae02d91dc3bc5fe6317439b2ad2f2a4bf0ad11e4e35132be71121fa)
- [apache-commons-lang3](https://commons.apache.org/proper/commons-lang/)
- [java-1.8.0-amazon-corretto](https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/amazon-linux-install.html)
