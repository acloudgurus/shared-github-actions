---
prev:
    text: Code Scanning
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/code-scan/python
===========================================================

Run Python code scanning using ReviewDog and mypy over Python modules. 

Findings will be added to your branches pull request, for further action.

### Assumptions

+ Python version >=3.10. Current shared runner defaults to 3.10, and would require running `actions/setup-python` to specify a different version from 3.10.
+ If using pipenv, An existing Pipfile is within the repository. 
+ If using Poetry, existing poetry configurations are set in pyproject.toml within the working directory (`workdir`).

### Permissions

+ the following permissions are needed:
```yaml
permissions:
  checks: write
  contents: read
  pull-requests: write
```

### Inputs
+ `reviewdog_version`
  + String argument for reviewdog. Defaults to `v0.20.1`.
  + type: `string`
+ `github_token`
  + GITHUB_TOKEN. Defaults to `github.token`.
  + type: `string`
+ `reporter`
  + Reporter of reviewdog command [github-pr-check,github-pr-review]. Defaults to `github-pr-check`.
  + type: `string`
+ `level`
  + Report level for reviewdog [info,warning,error]. Defaults to `error`.
  + type: `string`
+ `workdir`
  + Working directory of where to run mypy command. Relative to the root directory. Defaults to `.`.
  + type: `string`
+ `setup_command`
  + mypy setup command. Runs when "setup_method" is "install" or required by "adaptive". If you want to fix the version of mypy, set the value as in the following example. `pip install mypy==1.6.0`. Defaults to `pip install mypy`.
  + type: `string`
+ `setup_method`
  + mypy setup method. Select from below. `nothing` - no setup process. This option expects the user to prepare the environment (ex. previous workflow step executed `pip install -r requirements.txt`). If you do not want immediately package installation (e.g., in a poetry environment), must be this. `adaptive` - Check `execute_command` with `--version` is executable. If it can be executed, do the same as `nothing`, otherwise do the same as `install`. `install` - execute `setup_command`. Incorrect values behave as `adaptive`. Defaults to `nothing`.
  + type: `string`
+ `execute_command`
  + mypy execute command. Normally it is `mypy`, but for example `poetry run mypy` if you want to run at Poetry without activating the virtual environment. Defaults to `mypy`.
  + type: `string`
+ `filter_mode`
  + Filtering mode for the reviewdog command [added,diff_context,file,nofilter]. Defaults to `nofilter`.
  + type: `string`
+ `fail_on_error`
  + Exit code for reviewdog when errors are found [true,false]. Defaults to `false`.
  + type: `string`
+ `target`
  + Target files and/or directories of mypy command. Enumerate in a space-separated list. Relative to the working directory. Defaults to `.`.
  + type: `string`
+ `mypy_flags`
  + mypy options. Defaults to ``.
  + type: `string`
+ `output_json`
  + Use the JSON output format available in mypy 1.11 or higher. This option defaults to false due to version limitations and because it is still experimental. Note the mypy version when setting to true. Defaults to `false`.
  + type: `string`
+ `reviewdog_flags`
  + reviewdog flags Defaults to ``.
  + type: `string`

### Outputs

None

### Using this action, on pull request

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:
```
name: Python code quality scannning
env:
  SHELL_ENVIRONMENT: poetry
  TOML_PARENT_DIR:  'module/aws/lambda_code/actions_test/,module/aws/lambda_code/another_test/'

on:
  workflow_dispatch:
    inputs:
      debug_mode:
        description: 'Set level of information printed for pytest'
        required: false
        default: false
        type: boolean
  pull_request:
    branches: [main, master, next, develop, 'feature-**', 'hotfix-**']

permissions:
  checks: write
  contents: read
  pull-requests: write

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
      uses: zilvertonz/shared-github-actions/build/python/@v0
      with:
        toml_parent_dir: ${{ env.TOML_PARENT_DIR }}
        environment_usage: ${{ env.TOML_PARENT_DIR }}
    - name: Install Dependencies
      id: install_deps
      uses: zilvertonz/shared-github-actions/install/python/@v0
      with:
        environment_usage: ${{ env.TOML_PARENT_DIR }}
        toml_parent_dir: ${{ env.TOML_PARENT_DIR }}
        archived_package_path: ${{ steps.build_deps.outputs.python_whl_location }}
     - name: Run Python Code Scanning
      id: run_code_scanning
      uses: zilvertonz/shared-github-actions/code-scan/python@feature-racetm672-codequalitystage
      with:
        reviewdog_version: v0.20.1
        github_token: ${{ github.token }}
        reporter: github-pr-review
        level: 'error'
        workdir: module/aws
        target: lambda_code/actions_test lambda_code/another_test
        setup_command: 'poetry add mypy'
        setup_method: 'install'
        execute_command: 'poetry run mypy'
        fail_on_error: true
        output_json: true

```
