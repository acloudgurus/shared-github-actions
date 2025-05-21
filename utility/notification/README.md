---
prev:
    text: Utilities
    link: '../'
next:
    false
---
zilvertonz/shared-github-actions/utility/notification
=============================================================

A GitHub action to send a Webex notification


### Assumptions

+ A Silverton AWS role is required through RJ (https://github.com/zilvertonz/RJ/) for your repository
+ This RJ deployer role should be listed in the M2M Auth repo to allow access to the M2M token needed to call the Event Service. Instructions are detailed in the [API consumers documentation](https://github.com/zilvertonz/maa-m2m-auth/blob/main/API-CONSUMERS.md)
+ The RJ deployer role should also be granted access (i.e. `secretsmanager:GetSecretValue`) to its corresponding AWS Secrets Manager resource in the RJ's `template.yaml` configuration
+ Use a zilverton private runner to run the GitHub Action

> [!IMPORTANT]
> As stated above, use a private runner for this action or it will error.


### Notification Messages

The types of messages will be different depending on the trigger. Currently, there are 3 types of notification messages implemented: 
1. Deployment Notification
2. Pull Request Review Notification
3. Issue Created Notification

#### 1. Deployment Notification

**Message Type**
This notification sends a message about the status of a deployment. For example, the `deployment_status` can be set to return the status of a pipeline run

**Trigger** 
Push

**Inputs**
+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ event_service_consumer (required)
  + Name of the Event Service API consumer. Example: northstar
  + type: `string`
+ event_service_env (optional)
  + Environment name in which the Event Service API will be called. This can be omitted only if the deployment env is `prod`, otherwise it may result in a 401 error. Example: dev
  + default: `prod`
  + type: `string`
  + options: [`dev`, `test`, `prod`]
+ webex_room_id (optional, only processed in a Deployment Notification)
  + Webex room ID to which the notification should be sent. As a default, the notification will be sent to the person triggering the action if this input is not provided
  + type: `string`
+ deployment_status (required only for Deployment Notification)
  + Status of an application deployment (required when action is used for deployment notification). It can be used to notify that a pipeline run or process is a success or failure
  + type: `string`
+ deployment_env (required only for Deployment Notification)
  + Environment in which the application is deployed
  + type: `string`
+ deployment_tag (optional, only processed in a Deployment Notification)
  + Git tag associated with the deployment job
  + type: `string`

#### 2. Pull Request Review Notification

**Message Type**
This notification sends a private message to a person selected as the pull request reviewer. 

> [!NOTE]
> Requesting reviews from multiple people are currently not supported. The Webex notification will only be sent to the first person in Reviewers list.

**Trigger** 
Pull request: `review_requested`

**Inputs**
+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ event_service_consumer (required)
  + Name of the Event Service API consumer. Example: northstar
  + type: `string`
+ event_service_env (optional)
  + Environment name in which the Event Service API will be called. This can be omitted only if the deployment env is `prod`, otherwise it may result in a 401 error. Example: dev
  + default: `prod`
  + type: `string`
  + options: [`dev`, `test`, `prod`]

### 3. Issue Created Notification
This notification sends a message notifing the creation of an issue.

**Trigger** 
Issues: `opened`

**Inputs**
+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ event_service_consumer (required)
  + Name of the Event Service API consumer. Example: northstar
  + type: `string`
+ event_service_env (optional)
  + Environment name in which the Event Service API will be called. This can be omitted only if the deployment env is `prod`, otherwise it may result in a 401 error. Example: dev
  + default: `prod`
  + type: `string`
  + options: [`dev`, `test`, `prod`]
+ webex_room_id (optional, however necessary for Issue creation notification)
  + Webex room ID to which the notification should be sent.
  + type: `string`

### Notification Channels

+ Currently, the Event Service is only available to send messages via Webex private message to an individual or a Webex room id
+ Future enchancements are to include email notification and ServiceNow ticket creation


### All Possible Inputs

+ token (required)
  + A GitHub token for running GitHub CLI commands, most commonly the `GITHUB_TOKEN` secret
  + type: `string`
+ event_service_consumer (required)
  + Name of the Event Service API consumer. Example: northstar
  + type: `string`
+ event_service_env (optional)
  + Environment name in which the Event Service API will be called. This can be omitted only if the deployment env is `prod`, otherwise it may result in a 401 error. Example: dev
  + default: `prod`
  + type: `string`
  + options: [`dev`, `test`, `prod`]
+ webex_room_id (optional, only processed in a Deployment Notification)
  + Webex room ID to which the notification should be sent. As a default, the notification will be sent to the person triggering the action if this input is not provided
  + type: `string`
+ deployment_status (required only for Deployment Notification)
  + Status of an application deployment. It can be used to notify that a pipeline run or process is a success or failure
  + type: `string`
+ deployment_env (required only for Deployment Notification)
  + Environment in which the application is deployed
  + type: `string`
+ deployment_tag (optional, only processed in a Deployment Notification)
  + Git tag associated with the deployment job
  + type: `string`

### Permissions

+ Permissions required to allow the GitHub action to read commits and fetch OIDC token:
+ `contents:read` (required)
+ `id-token:write` (required)

### Using this action

To use this action, make a workflow file in `.github/workflows` and use it in a job definition:

#### 1. Example Deployment Notification Workflow
```yaml
name: Terragrunt Failure Deployment Notification

on:
  push:
    branches:
      - main
      - feat*

permissions:
  contents: read
  id-token: write

jobs:
  SendNotification:
    # Must use a private runner
    runs-on: zilverton-private-x64-ubuntu 
    environment: dev
    steps:
        - name: Terragrunt apply
          id: terragrunt
          uses: zilvertonz/shared-github-actions/deploy/terragrunt@v1
          env:
            TF_VAR_webex_bearer_token: ${{ secrets.WEBEX_BEARER_TOKEN }}
          with:
            token: ${{ secrets.ORG_REPO_READ_ACCESS }}
            module: module/aws/
            workspace: ${{ github.ref_name == 'main' && 'prod' || github.ref_name == 'test' && 'test' || 'dev' }}
            terraform_action: apply

        - name: Send Deployment Failure Notification
          if: ${{ failure() }}
          uses: zilvertonz/shared-github-actions/utility/notification@v1
          with:
            token: ${{ github.token }}
            event_service_consumer: northstar
            webex_room_id: <WEBEX_ROOM_ID>
            deployment_env: dev
            deployment_status: ${{ steps.terragrunt.outcome }}
            event_service_env: dev
```

This workflow is triggered to run on a push to any feature branch and the main branch.

The above Deployment Notification action will only be run if the previous terragrunt step failed (if condition: `failure()`).

This example uses the Terragrunt outcome to pass as the `deployment_status`. Other statuses such as any string value, outputs, or outcome from a previous step may also be used here instead.

A Webex room id (optional) is passed in this example to notify a team's Webex chat room.

> [!NOTE]
> As a default, the notification will be sent to the person who pushed the git changes via the Webex private message from the Alert Engine Bot if a `webex_room_id` is not provided

It uses the [M2M get-token GitHub action](https://github.com/zilvertonz/maa-m2m-auth/tree/main/actions/get-token) to fetch the token needed to call the Event Service API.

A Webex notification will be sent to the provided Webex room id via the Alert Engine Bot. It will include a clickable link to the repo, branch name, status, environment, and a link to the release if `deployment_tag` is provided (see screenshot below).

<img src="https://raw.githubusercontent.com/zilvertonz/shared-github-actions/refs/heads/main/utility/notification/deployment-notification.png" alt="Webex card displaying Deployment Notification" width="500">


#### 2. Example PR Review Notification Workflow
```yaml
name: Pull Request Review Notification

on:
  pull_request:
    types: 
      # triggers the action when a reviewer is added to the pull request
      - review_requested
    branches:
      # target branch for the pull request
      - main

permissions:
  contents: read
  id-token: write

jobs:
  SendNotification:
    # must use a private runner
    runs-on: zilverton-private-x64-ubuntu
    steps:
      - name: Send Pull Request Review Notification
        uses: zilvertonz/shared-github-actions/utility/notification@v1
        with:
          token: ${{ github.token }}
          event_service_consumer: northstar
          event_service_env: dev
```

This workflow is triggered to run when a reviewer is requested ([GitHub docs](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/requesting-a-pull-request-review)). 

> [!NOTE]
> Requesting reviews from multiple people are not supported. Webex notification will only be sent to the first person in Reviewers list.

It uses the [M2M get-token GitHub action](https://github.com/zilvertonz/maa-m2m-auth/tree/main/actions/get-token) to fetch the token needed to call the Event Service API.

A Webex notification will be sent to the reviewer via the Alert Engine Bot. It will include a clickable link to the pull request and the email addresss of the requester (see screenshot below).

![Webex card displaying Pull Request Review Notification](https://raw.githubusercontent.com/zilvertonz/shared-github-actions/refs/heads/main/utility/notification/pr-review-notification.png)

#### 2. Example PR Review Notification Workflow
```yaml
name: Issue Created Notification

on:
  issues:
    types: 
      # triggers the action when issue gets created
      - opened

permissions:
  contents: read
  id-token: write

jobs:
  SendNotification:
    # must use a private runner
    runs-on: zilverton-private-x64-ubuntu
    steps:
      - name: Send Issue Created Notification
        uses: zilvertonz/shared-github-actions/utility/notification@v1
        with:
          token: ${{ github.token }}
          event_service_consumer: northstar
          event_service_env: dev
          webex_room_id: "12345ab0-1b98-12cd-1234-65495d8c4bf9" # update to your webex room
```

This workflow is triggered to run when an issue is created. 

It uses the [M2M get-token GitHub action](https://github.com/zilvertonz/maa-m2m-auth/tree/main/actions/get-token) to fetch the token needed to call the Event Service API.

A Webex notification will be sent to the reviewer via the Alert Engine Bot. It will include a clickable link to the issue and the lan id of the creator.