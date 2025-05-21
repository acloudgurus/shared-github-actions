---
prev:
    text: Compliance
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/compliance/verify-approvers
===========================================================

A GitHub action to verify a compliant number of approvers on the current commit

### Assumptions

+ Your metric alarm resource is configured correctly with [Alarm-Service](https://github.com/zilvertonz/maa-alarm-service)

### Inputs

+ `token` (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`

+ `alarm-name` (required)
  + Name of the metric alarm to trigger
  + type: `string`

+ `environment` (required)
  + AWS Environment to run this action. Default is `prod`.
  + type: `string`

### Using this action

```
name: Gameday
run-name: "Gameday testing for alarm: ${{ inputs.alarm-name }} on ${{ inputs.environment }} environment"

on:
  workflow_dispatch:
    inputs:
      alarm-name:
        type: string
        required: false
        default: "maa-your-alarm"
      environment:
        type: string
        required: false
        default: prod
      

permissions:
  contents: read
  id-token: write
  checks: write
  actions: read

jobs:
  Gameday:
    name: Gameday
    runs-on: MA-Analytics-Runner
    environment:
      name: audit
    container:
      image: ghcr.io/zilvertonz/shared-github-actions:v1-base
      credentials:
        username: GTHBAUTO_Zilver
        password: ${{ secrets.ORG_REPO_READ_ACCESS }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set GitHub Read Acess Token
        run: git config --global url."https://${{ secrets.ORG_REPO_READ_ACCESS }}@github.com".insteadOf "https://github.com"

      - name: Gameday
        uses: zilvertonz/shared-github-actions/compliance/gameday@v1
        with:
          alarm-name: ${{ inputs.alarm-name }}
          token: ${{ secrets.GITHUB_TOKEN }}
          environment: ${{ inputs.environment }}
```

This workflow runs the Gameday shared action. When successful, a webex card alert will be sent the webex room defined.