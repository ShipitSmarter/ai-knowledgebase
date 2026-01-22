---
description: Test a backend service PR in local viya-app dev environment
---

Load the viya-dev-environment skill and help the user test a PR locally.

The user will provide either:
- A PR number and repo (e.g., "shipping PR 1277")
- A PR URL (e.g., "https://github.com/ShipitSmarter/shipping/pull/1277")

Steps:
1. Get the PR details and check if build succeeded using `gh pr checks`
2. Get the run ID from the successful "Docker build" job
3. Construct the version string: `0.0.0-pr.<PR_NUMBER>.<RUN_ID>`
4. Find the viya-app repository (check ~/git/viya-app or ask user for location) and update `dev/.env` with the new version
5. Offer to restart the service

If the build is still running or failed, inform the user and don't proceed.
