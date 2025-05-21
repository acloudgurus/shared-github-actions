#!/usr/bin/env bash
set -euo pipefail


REPO=$1
REF=${2:-refs/heads/main}
echo 'number,state,html_url,rule.id,rule.description,rule.severity,rule.security_severity_level,tool.name,most_recent_instance.ref,location.path,location.start_line,location.end_line,created_at,updated_at,dismissed_at,dismissed_by.login,dismissed_reason,dismissed_comment,fixed_at,auto_dismissed_at'
  # -f state=open -f ref=${REF} 
gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -X GET /repos/zilvertonz/$REPO/code-scanning/alerts \
  | jq -r '.[] |
    [
        .number,
        .state,
        .html_url,
        .rule.id,
        .rule.description,
        .rule.severity,
        .rule.security_severity_level,
        .tool.name,
        .most_recent_instance.ref,
        .location.path,
        .location.start_line,
        .location.end_line,
        .created_at,
        .updated_at,
        .dismissed_at,
        .dismissed_by.login,
        .dismissed_reason,
        .dismissed_comment,
        .fixed_at,
        .auto_dismissed_at
    ] | @csv'
# echo'[
#   {
#     "number": 5,
#     "created_at": "2024-12-27T16:15:10Z",
#     "updated_at": "2025-01-17T17:53:18Z",
#     "url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/5",
#     "html_url": "https://github.com/zilvertonz/gedp-databricks-infra/security/code-scanning/5",
#     "state": "dismissed",
#     "fixed_at": "2025-01-17T22:19:37Z",
#     "dismissed_by": {
#       "login": "C7R2QT_Zilver",
#       "id": 175133535,
#       "node_id": "U_kgDOCnBTXw",
#       "avatar_url": "https://avatars.githubusercontent.com/u/175133535?v=4",
#       "gravatar_id": "",
#       "url": "https://api.github.com/users/C7R2QT_Zilver",
#       "html_url": "https://github.com/C7R2QT_Zilver",
#       "followers_url": "https://api.github.com/users/C7R2QT_Zilver/followers",
#       "following_url": "https://api.github.com/users/C7R2QT_Zilver/following{/other_user}",
#       "gists_url": "https://api.github.com/users/C7R2QT_Zilver/gists{/gist_id}",
#       "starred_url": "https://api.github.com/users/C7R2QT_Zilver/starred{/owner}{/repo}",
#       "subscriptions_url": "https://api.github.com/users/C7R2QT_Zilver/subscriptions",
#       "organizations_url": "https://api.github.com/users/C7R2QT_Zilver/orgs",
#       "repos_url": "https://api.github.com/users/C7R2QT_Zilver/repos",
#       "events_url": "https://api.github.com/users/C7R2QT_Zilver/events{/privacy}",
#       "received_events_url": "https://api.github.com/users/C7R2QT_Zilver/received_events",
#       "type": "User",
#       "user_view_type": "public",
#       "site_admin": false
#     },
#     "dismissed_at": "2025-01-17T17:53:18Z",
#     "dismissed_reason": "false positive",
#     "dismissed_comment": "the value of the variable 'secret_scope_name' is not a secret.",
#     "rule": {
#       "id": "py/clear-text-logging-sensitive-data",
#       "severity": "error",
#       "description": "Clear-text logging of sensitive information",
#       "name": "py/clear-text-logging-sensitive-data",
#       "tags": [
#         "external/cwe/cwe-312",
#         "external/cwe/cwe-359",
#         "external/cwe/cwe-532",
#         "security"
#       ],
#       "full_description": "Logging sensitive information without encryption or hashing can expose it to an attacker.",
#       "help": "# Clear-text logging of sensitive information\nIf sensitive data is written to a log entry it could be exposed to an attacker who gains access to the logs.\n\nPotential attackers can obtain sensitive user data when the log output is displayed. Additionally that data may expose system information such as full path names, system information, and sometimes usernames and passwords.\n\n\n## Recommendation\nSensitive data should not be logged.\n\n\n## Example\nIn the example the entire process environment is logged using \\`print\\`. Regular users of the production deployed application should not have access to this much information about the environment configuration.\n\n\n```python\n# BAD: Logging cleartext sensitive data\nimport os\nprint(f\"[INFO] Environment: {os.environ}\")\n```\nIn the second example the data that is logged is not sensitive.\n\n\n```python\nnot_sensitive_data = {'a': 1, 'b': 2}\n# GOOD: it is fine to log data that is not sensitive\nprint(f\"[INFO] Some object contains: {not_sensitive_data}\")\n```\n\n## References\n* OWASP: [Insertion of Sensitive Information into Log File](https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/).\n* Common Weakness Enumeration: [CWE-312](https://cwe.mitre.org/data/definitions/312.html).\n* Common Weakness Enumeration: [CWE-359](https://cwe.mitre.org/data/definitions/359.html).\n* Common Weakness Enumeration: [CWE-532](https://cwe.mitre.org/data/definitions/532.html).\n",
#       "security_severity_level": "high"
#     },
#     "tool": {
#       "name": "CodeQL",
#       "guid": null,
#       "version": "2.20.4"
#     },
#     "most_recent_instance": {
#       "ref": "refs/heads/develop",
#       "analysis_key": "dynamic/github-code-scanning/codeql:analyze",
#       "environment": "{\"build-mode\":\"none\",\"category\":\"/language:python\",\"language\":\"python\",\"runner\":\"[\\\"code-scanning\\\"]\"}",
#       "category": "/language:python",
#       "state": "dismissed",
#       "commit_sha": "5673b0cbe67635f76202d6f328795be3a3881c3b",
#       "message": {
#         "text": "This expression logs sensitive data (secret) as clear text."
#       },
#       "location": {
#         "path": "module/databricks/workspace_admin/artifacts/notebooks/provision_personal_secret_scope.py",
#         "start_line": 36,
#         "end_line": 36,
#         "start_column": 15,
#         "end_column": 149
#       },
#       "classifications": []
#     },
#     "instances_url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/5/instances",
#     "dismissal_approved_by": null
#   },
#   {
#     "number": 4,
#     "created_at": "2024-12-27T16:15:10Z",
#     "updated_at": "2025-01-17T17:53:42Z",
#     "url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/4",
#     "html_url": "https://github.com/zilvertonz/gedp-databricks-infra/security/code-scanning/4",
#     "state": "dismissed",
#     "fixed_at": "2025-01-17T22:19:37Z",
#     "dismissed_by": {
#       "login": "C7R2QT_Zilver",
#       "id": 175133535,
#       "node_id": "U_kgDOCnBTXw",
#       "avatar_url": "https://avatars.githubusercontent.com/u/175133535?v=4",
#       "gravatar_id": "",
#       "url": "https://api.github.com/users/C7R2QT_Zilver",
#       "html_url": "https://github.com/C7R2QT_Zilver",
#       "followers_url": "https://api.github.com/users/C7R2QT_Zilver/followers",
#       "following_url": "https://api.github.com/users/C7R2QT_Zilver/following{/other_user}",
#       "gists_url": "https://api.github.com/users/C7R2QT_Zilver/gists{/gist_id}",
#       "starred_url": "https://api.github.com/users/C7R2QT_Zilver/starred{/owner}{/repo}",
#       "subscriptions_url": "https://api.github.com/users/C7R2QT_Zilver/subscriptions",
#       "organizations_url": "https://api.github.com/users/C7R2QT_Zilver/orgs",
#       "repos_url": "https://api.github.com/users/C7R2QT_Zilver/repos",
#       "events_url": "https://api.github.com/users/C7R2QT_Zilver/events{/privacy}",
#       "received_events_url": "https://api.github.com/users/C7R2QT_Zilver/received_events",
#       "type": "User",
#       "user_view_type": "public",
#       "site_admin": false
#     },
#     "dismissed_at": "2025-01-17T17:53:42Z",
#     "dismissed_reason": "false positive",
#     "dismissed_comment": "the value of the variable 'secret_scope_name' is not a secret.",
#     "rule": {
#       "id": "py/clear-text-logging-sensitive-data",
#       "severity": "error",
#       "description": "Clear-text logging of sensitive information",
#       "name": "py/clear-text-logging-sensitive-data",
#       "tags": [
#         "external/cwe/cwe-312",
#         "external/cwe/cwe-359",
#         "external/cwe/cwe-532",
#         "security"
#       ],
#       "full_description": "Logging sensitive information without encryption or hashing can expose it to an attacker.",
#       "help": "# Clear-text logging of sensitive information\nIf sensitive data is written to a log entry it could be exposed to an attacker who gains access to the logs.\n\nPotential attackers can obtain sensitive user data when the log output is displayed. Additionally that data may expose system information such as full path names, system information, and sometimes usernames and passwords.\n\n\n## Recommendation\nSensitive data should not be logged.\n\n\n## Example\nIn the example the entire process environment is logged using \\`print\\`. Regular users of the production deployed application should not have access to this much information about the environment configuration.\n\n\n```python\n# BAD: Logging cleartext sensitive data\nimport os\nprint(f\"[INFO] Environment: {os.environ}\")\n```\nIn the second example the data that is logged is not sensitive.\n\n\n```python\nnot_sensitive_data = {'a': 1, 'b': 2}\n# GOOD: it is fine to log data that is not sensitive\nprint(f\"[INFO] Some object contains: {not_sensitive_data}\")\n```\n\n## References\n* OWASP: [Insertion of Sensitive Information into Log File](https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/).\n* Common Weakness Enumeration: [CWE-312](https://cwe.mitre.org/data/definitions/312.html).\n* Common Weakness Enumeration: [CWE-359](https://cwe.mitre.org/data/definitions/359.html).\n* Common Weakness Enumeration: [CWE-532](https://cwe.mitre.org/data/definitions/532.html).\n",
#       "security_severity_level": "high"
#     },
#     "tool": {
#       "name": "CodeQL",
#       "guid": null,
#       "version": "2.20.4"
#     },
#     "most_recent_instance": {
#       "ref": "refs/heads/develop",
#       "analysis_key": "dynamic/github-code-scanning/codeql:analyze",
#       "environment": "{\"build-mode\":\"none\",\"category\":\"/language:python\",\"language\":\"python\",\"runner\":\"[\\\"code-scanning\\\"]\"}",
#       "category": "/language:python",
#       "state": "dismissed",
#       "commit_sha": "5673b0cbe67635f76202d6f328795be3a3881c3b",
#       "message": {
#         "text": "This expression logs sensitive data (secret) as clear text."
#       },
#       "location": {
#         "path": "module/databricks/workspace_admin/artifacts/notebooks/provision_personal_secret_scope.py",
#         "start_line": 34,
#         "end_line": 34,
#         "start_column": 15,
#         "end_column": 74
#       },
#       "classifications": []
#     },
#     "instances_url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/4/instances",
#     "dismissal_approved_by": null
#   },
#   {
#     "number": 3,
#     "created_at": "2024-12-27T16:15:10Z",
#     "updated_at": "2025-01-17T17:53:53Z",
#     "url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/3",
#     "html_url": "https://github.com/zilvertonz/gedp-databricks-infra/security/code-scanning/3",
#     "state": "dismissed",
#     "fixed_at": "2025-01-17T22:19:37Z",
#     "dismissed_by": {
#       "login": "C7R2QT_Zilver",
#       "id": 175133535,
#       "node_id": "U_kgDOCnBTXw",
#       "avatar_url": "https://avatars.githubusercontent.com/u/175133535?v=4",
#       "gravatar_id": "",
#       "url": "https://api.github.com/users/C7R2QT_Zilver",
#       "html_url": "https://github.com/C7R2QT_Zilver",
#       "followers_url": "https://api.github.com/users/C7R2QT_Zilver/followers",
#       "following_url": "https://api.github.com/users/C7R2QT_Zilver/following{/other_user}",
#       "gists_url": "https://api.github.com/users/C7R2QT_Zilver/gists{/gist_id}",
#       "starred_url": "https://api.github.com/users/C7R2QT_Zilver/starred{/owner}{/repo}",
#       "subscriptions_url": "https://api.github.com/users/C7R2QT_Zilver/subscriptions",
#       "organizations_url": "https://api.github.com/users/C7R2QT_Zilver/orgs",
#       "repos_url": "https://api.github.com/users/C7R2QT_Zilver/repos",
#       "events_url": "https://api.github.com/users/C7R2QT_Zilver/events{/privacy}",
#       "received_events_url": "https://api.github.com/users/C7R2QT_Zilver/received_events",
#       "type": "User",
#       "user_view_type": "public",
#       "site_admin": false
#     },
#     "dismissed_at": "2025-01-17T17:53:53Z",
#     "dismissed_reason": "false positive",
#     "dismissed_comment": "the value of the variable 'secret_scope_name' is not a secret.",
#     "rule": {
#       "id": "py/clear-text-logging-sensitive-data",
#       "severity": "error",
#       "description": "Clear-text logging of sensitive information",
#       "name": "py/clear-text-logging-sensitive-data",
#       "tags": [
#         "external/cwe/cwe-312",
#         "external/cwe/cwe-359",
#         "external/cwe/cwe-532",
#         "security"
#       ],
#       "full_description": "Logging sensitive information without encryption or hashing can expose it to an attacker.",
#       "help": "# Clear-text logging of sensitive information\nIf sensitive data is written to a log entry it could be exposed to an attacker who gains access to the logs.\n\nPotential attackers can obtain sensitive user data when the log output is displayed. Additionally that data may expose system information such as full path names, system information, and sometimes usernames and passwords.\n\n\n## Recommendation\nSensitive data should not be logged.\n\n\n## Example\nIn the example the entire process environment is logged using \\`print\\`. Regular users of the production deployed application should not have access to this much information about the environment configuration.\n\n\n```python\n# BAD: Logging cleartext sensitive data\nimport os\nprint(f\"[INFO] Environment: {os.environ}\")\n```\nIn the second example the data that is logged is not sensitive.\n\n\n```python\nnot_sensitive_data = {'a': 1, 'b': 2}\n# GOOD: it is fine to log data that is not sensitive\nprint(f\"[INFO] Some object contains: {not_sensitive_data}\")\n```\n\n## References\n* OWASP: [Insertion of Sensitive Information into Log File](https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/).\n* Common Weakness Enumeration: [CWE-312](https://cwe.mitre.org/data/definitions/312.html).\n* Common Weakness Enumeration: [CWE-359](https://cwe.mitre.org/data/definitions/359.html).\n* Common Weakness Enumeration: [CWE-532](https://cwe.mitre.org/data/definitions/532.html).\n",
#       "security_severity_level": "high"
#     },
#     "tool": {
#       "name": "CodeQL",
#       "guid": null,
#       "version": "2.20.4"
#     },
#     "most_recent_instance": {
#       "ref": "refs/heads/develop",
#       "analysis_key": "dynamic/github-code-scanning/codeql:analyze",
#       "environment": "{\"build-mode\":\"none\",\"category\":\"/language:python\",\"language\":\"python\",\"runner\":\"[\\\"code-scanning\\\"]\"}",
#       "category": "/language:python",
#       "state": "dismissed",
#       "commit_sha": "5673b0cbe67635f76202d6f328795be3a3881c3b",
#       "message": {
#         "text": "This expression logs sensitive data (secret) as clear text."
#       },
#       "location": {
#         "path": "module/databricks/workspace_admin/artifacts/notebooks/provision_personal_secret_scope.py",
#         "start_line": 32,
#         "end_line": 32,
#         "start_column": 15,
#         "end_column": 122
#       },
#       "classifications": []
#     },
#     "instances_url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/3/instances",
#     "dismissal_approved_by": null
#   },
#   {
#     "number": 2,
#     "created_at": "2024-12-27T16:15:10Z",
#     "updated_at": "2025-01-17T17:54:05Z",
#     "url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/2",
#     "html_url": "https://github.com/zilvertonz/gedp-databricks-infra/security/code-scanning/2",
#     "state": "dismissed",
#     "fixed_at": "2025-01-17T22:19:37Z",
#     "dismissed_by": {
#       "login": "C7R2QT_Zilver",
#       "id": 175133535,
#       "node_id": "U_kgDOCnBTXw",
#       "avatar_url": "https://avatars.githubusercontent.com/u/175133535?v=4",
#       "gravatar_id": "",
#       "url": "https://api.github.com/users/C7R2QT_Zilver",
#       "html_url": "https://github.com/C7R2QT_Zilver",
#       "followers_url": "https://api.github.com/users/C7R2QT_Zilver/followers",
#       "following_url": "https://api.github.com/users/C7R2QT_Zilver/following{/other_user}",
#       "gists_url": "https://api.github.com/users/C7R2QT_Zilver/gists{/gist_id}",
#       "starred_url": "https://api.github.com/users/C7R2QT_Zilver/starred{/owner}{/repo}",
#       "subscriptions_url": "https://api.github.com/users/C7R2QT_Zilver/subscriptions",
#       "organizations_url": "https://api.github.com/users/C7R2QT_Zilver/orgs",
#       "repos_url": "https://api.github.com/users/C7R2QT_Zilver/repos",
#       "events_url": "https://api.github.com/users/C7R2QT_Zilver/events{/privacy}",
#       "received_events_url": "https://api.github.com/users/C7R2QT_Zilver/received_events",
#       "type": "User",
#       "user_view_type": "public",
#       "site_admin": false
#     },
#     "dismissed_at": "2025-01-17T17:54:05Z",
#     "dismissed_reason": "false positive",
#     "dismissed_comment": "the value of the variable 'secret_scope_name' is not a secret.",
#     "rule": {
#       "id": "py/clear-text-logging-sensitive-data",
#       "severity": "error",
#       "description": "Clear-text logging of sensitive information",
#       "name": "py/clear-text-logging-sensitive-data",
#       "tags": [
#         "external/cwe/cwe-312",
#         "external/cwe/cwe-359",
#         "external/cwe/cwe-532",
#         "security"
#       ],
#       "full_description": "Logging sensitive information without encryption or hashing can expose it to an attacker.",
#       "help": "# Clear-text logging of sensitive information\nIf sensitive data is written to a log entry it could be exposed to an attacker who gains access to the logs.\n\nPotential attackers can obtain sensitive user data when the log output is displayed. Additionally that data may expose system information such as full path names, system information, and sometimes usernames and passwords.\n\n\n## Recommendation\nSensitive data should not be logged.\n\n\n## Example\nIn the example the entire process environment is logged using \\`print\\`. Regular users of the production deployed application should not have access to this much information about the environment configuration.\n\n\n```python\n# BAD: Logging cleartext sensitive data\nimport os\nprint(f\"[INFO] Environment: {os.environ}\")\n```\nIn the second example the data that is logged is not sensitive.\n\n\n```python\nnot_sensitive_data = {'a': 1, 'b': 2}\n# GOOD: it is fine to log data that is not sensitive\nprint(f\"[INFO] Some object contains: {not_sensitive_data}\")\n```\n\n## References\n* OWASP: [Insertion of Sensitive Information into Log File](https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/).\n* Common Weakness Enumeration: [CWE-312](https://cwe.mitre.org/data/definitions/312.html).\n* Common Weakness Enumeration: [CWE-359](https://cwe.mitre.org/data/definitions/359.html).\n* Common Weakness Enumeration: [CWE-532](https://cwe.mitre.org/data/definitions/532.html).\n",
#       "security_severity_level": "high"
#     },
#     "tool": {
#       "name": "CodeQL",
#       "guid": null,
#       "version": "2.20.4"
#     },
#     "most_recent_instance": {
#       "ref": "refs/heads/develop",
#       "analysis_key": "dynamic/github-code-scanning/codeql:analyze",
#       "environment": "{\"build-mode\":\"none\",\"category\":\"/language:python\",\"language\":\"python\",\"runner\":\"[\\\"code-scanning\\\"]\"}",
#       "category": "/language:python",
#       "state": "dismissed",
#       "commit_sha": "5673b0cbe67635f76202d6f328795be3a3881c3b",
#       "message": {
#         "text": "This expression logs sensitive data (secret) as clear text."
#       },
#       "location": {
#         "path": "module/databricks/workspace_admin/artifacts/notebooks/provision_personal_secret_scope.py",
#         "start_line": 50,
#         "end_line": 50,
#         "start_column": 15,
#         "end_column": 126
#       },
#       "classifications": []
#     },
#     "instances_url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/2/instances",
#     "dismissal_approved_by": null
#   },
#   {
#     "number": 1,
#     "created_at": "2024-12-27T16:15:10Z",
#     "updated_at": "2025-01-17T17:54:16Z",
#     "url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/1",
#     "html_url": "https://github.com/zilvertonz/gedp-databricks-infra/security/code-scanning/1",
#     "state": "dismissed",
#     "fixed_at": "2025-01-17T22:19:37Z",
#     "dismissed_by": {
#       "login": "C7R2QT_Zilver",
#       "id": 175133535,
#       "node_id": "U_kgDOCnBTXw",
#       "avatar_url": "https://avatars.githubusercontent.com/u/175133535?v=4",
#       "gravatar_id": "",
#       "url": "https://api.github.com/users/C7R2QT_Zilver",
#       "html_url": "https://github.com/C7R2QT_Zilver",
#       "followers_url": "https://api.github.com/users/C7R2QT_Zilver/followers",
#       "following_url": "https://api.github.com/users/C7R2QT_Zilver/following{/other_user}",
#       "gists_url": "https://api.github.com/users/C7R2QT_Zilver/gists{/gist_id}",
#       "starred_url": "https://api.github.com/users/C7R2QT_Zilver/starred{/owner}{/repo}",
#       "subscriptions_url": "https://api.github.com/users/C7R2QT_Zilver/subscriptions",
#       "organizations_url": "https://api.github.com/users/C7R2QT_Zilver/orgs",
#       "repos_url": "https://api.github.com/users/C7R2QT_Zilver/repos",
#       "events_url": "https://api.github.com/users/C7R2QT_Zilver/events{/privacy}",
#       "received_events_url": "https://api.github.com/users/C7R2QT_Zilver/received_events",
#       "type": "User",
#       "user_view_type": "public",
#       "site_admin": false
#     },
#     "dismissed_at": "2025-01-17T17:54:16Z",
#     "dismissed_reason": "false positive",
#     "dismissed_comment": "the value of the variable 'secret_scope_name' is not a secret.",
#     "rule": {
#       "id": "py/clear-text-logging-sensitive-data",
#       "severity": "error",
#       "description": "Clear-text logging of sensitive information",
#       "name": "py/clear-text-logging-sensitive-data",
#       "tags": [
#         "external/cwe/cwe-312",
#         "external/cwe/cwe-359",
#         "external/cwe/cwe-532",
#         "security"
#       ],
#       "full_description": "Logging sensitive information without encryption or hashing can expose it to an attacker.",
#       "help": "# Clear-text logging of sensitive information\nIf sensitive data is written to a log entry it could be exposed to an attacker who gains access to the logs.\n\nPotential attackers can obtain sensitive user data when the log output is displayed. Additionally that data may expose system information such as full path names, system information, and sometimes usernames and passwords.\n\n\n## Recommendation\nSensitive data should not be logged.\n\n\n## Example\nIn the example the entire process environment is logged using \\`print\\`. Regular users of the production deployed application should not have access to this much information about the environment configuration.\n\n\n```python\n# BAD: Logging cleartext sensitive data\nimport os\nprint(f\"[INFO] Environment: {os.environ}\")\n```\nIn the second example the data that is logged is not sensitive.\n\n\n```python\nnot_sensitive_data = {'a': 1, 'b': 2}\n# GOOD: it is fine to log data that is not sensitive\nprint(f\"[INFO] Some object contains: {not_sensitive_data}\")\n```\n\n## References\n* OWASP: [Insertion of Sensitive Information into Log File](https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/).\n* Common Weakness Enumeration: [CWE-312](https://cwe.mitre.org/data/definitions/312.html).\n* Common Weakness Enumeration: [CWE-359](https://cwe.mitre.org/data/definitions/359.html).\n* Common Weakness Enumeration: [CWE-532](https://cwe.mitre.org/data/definitions/532.html).\n",
#       "security_severity_level": "high"
#     },
#     "tool": {
#       "name": "CodeQL",
#       "guid": null,
#       "version": "2.20.4"
#     },
#     "most_recent_instance": {
#       "ref": "refs/heads/develop",
#       "analysis_key": "dynamic/github-code-scanning/codeql:analyze",
#       "environment": "{\"build-mode\":\"none\",\"category\":\"/language:python\",\"language\":\"python\",\"runner\":\"[\\\"code-scanning\\\"]\"}",
#       "category": "/language:python",
#       "state": "dismissed",
#       "commit_sha": "5673b0cbe67635f76202d6f328795be3a3881c3b",
#       "message": {
#         "text": "This expression logs sensitive data (secret) as clear text."
#       },
#       "location": {
#         "path": "module/databricks/workspace_admin/artifacts/notebooks/provision_personal_secret_scope.py",
#         "start_line": 40,
#         "end_line": 40,
#         "start_column": 7,
#         "end_column": 91
#       },
#       "classifications": []
#     },
#     "instances_url": "https://api.github.com/repos/zilvertonz/gedp-databricks-infra/code-scanning/alerts/1/instances",
#     "dismissal_approved_by": null
#   }
# ]'
