---
prev:
    text: Images
    link: '../'
next:
    text: Glue 4.0 Image
    link: '../glue4/'
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
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
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

> [!WARNING]
> `kubectl` on this image is deprecated. Please use the [k8s](../k8s/) image. `kubectl` will be by March 1st, 2025.

#### Always Installed
- [aws cli](https://aws.amazon.com/cli/)
- [jq](https://jqlang.github.io/jq/)
- [gh cli](https://cli.github.com/)
- python 3.9
- pip
- [uv](https://docs.astral.sh/uv/)

#### Python and `uv`
Python 3.9 and pip is pre-installed by default and can be used by running 
python3 and pip. Python 3.12 is installed with `uv` and can be utilized through 
the uv cli. Review the [Cheatsheet](#uv-cheatsheet) below for more info.

It is recommended to use `uv` for installing python dependencies, configuring virtual environments, etc.
`uv` is a feature full python package and project manager written in rust with impressive optimizations (10 - 100 times faster than pip when installing deps)

##### `uv` Cheatsheet

Please review documentation for more information: [uv](https://docs.astral.sh/uv/)

Run a python cli (like poetry) hosted in [PyPI](https://pypi.org/) using `uvx`. 
`uvx` will download and run the cli in the same command. `uvx` will cache the downloads
and simply run it after first install.
```bash
uvx poetry
```

Install a python cli (like poetry) hosted in [PyPI](https://pypi.org/) using `uv tool install`
```bash
uv tool install poetry
```

Create a virtual environment for an isolating installs/environment/etc. This 
creates a `.venv` directory in the current working directory for you to activate 
with `source .venv/bin/activate`. See docs for more options.
```bash
uv venv
# or specify python 3.12
uv venv --python 3.12
```

Once you have a virtual environment installed, you can run sub-commands like the 
following:

```bash
# must create the venv
uv venv --python 3.12

# install deps with pip
uv pip install pandas

# run a test script with pandas as one of the deps
uv run ./test.py
```

There's much more to `uv`. See documentation for more: [uv](https://docs.astral.sh/uv/)
