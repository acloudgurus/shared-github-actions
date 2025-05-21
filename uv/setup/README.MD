# GitHub Action: UV Python Setup

This GitHub Action sets up **Python** using `uv`, pins the version, and installs additional tools as specified.

## Features

- **Installs Python** using `uv python install`
- **Pins the specified Python version** for consistency.
- **Installs additional tools** (like `poetry`, `tox`, etc.)
- **Adds UV-installed tools to the GitHb Actions `$PATH`**

## Inputs
| Input     | Required | Default Value | Description                                              |
|-----------|----------|-------------------------|------------------------------------------------|
|`python_version`|   No     |       `3.9`        | Python version to install and pin              |
|`install_tools`|   No     |       `""` (empty)  | Multi-line list of additional tools to install |

## Usage

Here's a basic example of how to use this action in your workflow:

```yaml
- name: Setup Python with uv
  uses: zilvertonz/shared-github-actions/uv/setup@v1
```
**This installs Python 3.9 (default) with `uv` but no additional tools**

---

**Installing Python + additional tools**

```yaml
- name: Setup Python with uv
  uses: zilvertonz/shared-github-actions/uv/setup@v1
  with:
    python_version: "3.11"
    install_tools: |
        poetry
        tox==4.11.3
```

**Installing Python + additional tools with dependencies**

```yaml
- name: Setup Python with uv
  uses: zilvertonz/shared-github-actions/uv/setup@v1
  with:
    python_version: "3.11"
    install_tools: |
        poetry
        tox --with tox-uv
```


## How It Works

1. **Install and Pin Python Version**:
    The action uses `uv python install ${{ inputs.python_version }}` and `uv python pin ${{ inputs.python_version }}`

2. **Handles Multi-Line Tool Inputs**:
    - Cleans Windows-style carriage returns (`/r`)
    - Iterates over each tool and install it using `uv tool install "$tool"`

3. **Adds UV Tools to the System `$PATH`**:
    By running `echo "/github/home/.local/bin" >> "$GITHUB_PATH"` makes all installed tools available in other steps within the workflow.