---
prev:
    text: Lint
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/lint/python
===========================================================

A GitHub action to Lint Python Scripts.

### Assumptions

+ Python version >=3.10. Current shared runner defaults to 3.10, and would require running `actions/setup-python` to specify a different version from 3.10.
+ An existing pyproject.toml within the repository.
+ If using pipenv, An existing Pipfile is within the repository. 
+ If using Poetry, existing poetry configurations are set in pyproject.toml

### Permissions

### Inputs

+ `toml_parent_dir`
  + Points to directory containing PyProject TOML file to use. Defaults to `.`
  + type: `string`
+ `environment_usage`
  + Setting for python package manager used for dependencies. Currently supported are `pip`, `poetry`, `pipenv`. Defaults to `pip`. `poetry` recommended.
  + type: `string`
+ `additional_args`
  + Extra space-separated arguments to pass to Ruff command. Defaults to `""`
  + type: `string`

### Outputs

None

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```
name: Lint Python Scripts

on:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  LintPython:
    runs-on: MA-Analytics-Runner
    steps:
    - uses: actions/checkout@v4
    - name: Set up Python 3.10
      uses: actions/setup-python@v5
      with:
        python-version: '3.10'
    - name: Install Dependencies
      id: install_deps
      uses: zilvertonz/shared-github-actions/install/python@v1
      with:
        environment_usage: 'poetry'
        toml_parent_dir: 'module/aws/lambda_code'
        whl_package_path: ${{ steps.build_deps.outputs.python_whl_location }}
        additional_dependencies: 'numpy pandas pyarrow'
    - name: Lint Python
      id: lint_python
      uses: zilvertonz/shared-github-actions/lint/python@v1
      with:
        environment_usage:  'poetry'
        toml_parent_dir: 'module/aws/lambda_code'

```

This workflow will run a job `LintPython` which will fail if toml_parent_dir is invalid, or environment used does not have requirements set for it. The step `Install Dependencies` will install the python project. The subsequent step `Lint Python` will run [Ruff command](https://docs.astral.sh/ruff/) and error if any linting errors found.
