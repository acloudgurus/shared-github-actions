---
prev:
    text: Build
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/build/python
===========================================================

A GitHub action to build and make available a python wheel file.

### Assumptions

+ Python version >=3.10. Current shared runner defaults to 3.10, and would require running `actions/setup-python` to specify a different version from 3.10.
+ An existing pyproject.toml within the repository.
+ pyproject.toml has defined `include` keywords for build to point to. See [examples here](https://python-poetry.org/docs/pyproject/#include-and-exclude)
+ If using pipenv, An existing Pipfile is within the repository. 
+ If using Poetry, existing poetry configurations are set in pyproject.toml

### Permissions

+ `contents: read`
  + Required to read contents

### Inputs

+ `build_output_path`
  + Output of Build Path. Defaults to './dist'
  + type: string
+ `build_format`
  +  Sets whether the result of the build is in 'wheel' format or in 'sdist' format. If empty string, will build both. Defaults to 'wheel'
  + type: string
+ `environment_usage`
  + Setting for python package manager used for dependencies. Currently supported are `pip`, `poetry`, `pipenv`. Default to `pip`. `poetry` recommended.
  + type: `string`
+ `post_build_command`
  + A single-statement for executing a bash command after building of the archive is complete (e.g. `ls -Rt .`)
  + type: 
+ `toml_parent_dir`
  + Parent directory which contains one or more tomls in subdirectories. Defaults to `.`
  + type: `string`
+ `pre_run_command`
  + This is a command that will run at the beginning of each loop before running the build for each python env. This command should be passed by the repo leveraging this share action
  + type: `string`

### Outputs

+ `python_whl_location`
  + Absolute file location pointing towards whl file if built.If multiple were built, then a comma-separated string.
+ `python_build_location`
  + Absolute directory location pointing towards directory containing any build files.If multiple were built, then a comma-separated string.
+ `python_sdist_location`
  + Absolute file location pointing towards sdist file if built.If multiple were built, then a comma-separated string.

### Using this action (default)

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```
name: Build Python Package

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  BuildInstallPython:
    runs-on: MA-Analytics-Runner
    steps:
    - uses: actions/checkout@v4
    - name: Set up Python 3.10
      uses: actions/setup-python@v5
      with:
        python-version: '3.10'
    - name: Build Dependencies
      id: build_deps
      uses: zilvertonz/shared-github-actions/build/python/@v1
      with:
        toml_parent_dir: 'module/aws/lambda_code'
        environment_usage: 'poetry'
    - name: Install Dependencies
      id: install_deps
      uses: zilvertonz/shared-github-actions/install/python/@v1
      with:
        environment_usage: 'poetry'
        toml_parent_dir: 'module/aws/lambda_code'
        whl_package_path: ${{ steps.build_deps.outputs.python_whl_location }}

```

This workflow will run a job `BuildInstallPython` which will fail if toml_parent_dir is invalid, or environment used does not have requirements set for it. The step `Build Dependencies` will create a wheel file. The subsequent step `Install Dependencies` takes the output of `Build Dependencies` to pass the wheel file information for installation.

If artifacts will be used across multiple workflows or jobs refer to Github Actions upload-artifact (https://github.com/actions/upload-artifact) and download-artifact (https://github.com/actions/download-artifact). Once the Build Dependencies step is complete the upload-artifact action can be added to upload an artifact. More information can be found here: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow.