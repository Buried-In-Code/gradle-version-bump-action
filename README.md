# Gradle Version Bump Action

A simple Github action to bump the version of Gradle projects.

When using the sample below, this action will bump the version based on the pull-request tag.
For example, a pull request with the tag `minor` when closed and merged will update the version from `1.2.3` to `1.3.0`.

## Sample Usage
```yaml
name: Bump Version
on:
  pull_request_target:
    types:
      - closed

jobs:
  version_bump:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
        with:
          fetch-depth: 1
      - name: Major bump
        if: contains(github.event.pull_request.labels.*.name, "major")
        uses: Buried-In-Code/gradle-version-bump-action@v1
        with:
          github-token: ${{ secrets.github_token }}
          bump-mode: major
      - name: Minor bump
        if: contains(github.event.pull_request.labels.*.name, "minor")
        uses: Buried-In-Code/gradle-version-bump-action@v1
        with:
          github-token: ${{ secrets.github_token }}
          bump-mode: minor
      - name: Patch bump
        if: contains(github.event.pull_request.labels.*.name, "patch")
        uses: Buried-In-Code/gradle-version-bump-action@v1
        with:
          github-token: ${{ secrets.github_token }}
          bump-mode: patch
```

## Supported Arguments
 - `github-token`: Can either be the default token, _as seen above_, or a personal access token with write access to the repository.
 - `git-email`: The email address each commit should be associated with. **Default**: 6057651+github-actions[bot]@users.noreply.github.com
 - `git-username`: The username each commit should be associated with. **Default**: Github-Actions[bot]
 - `bump-mode`: Mode for version bump. **Options**: major, minor, patch. **Default**: patch

## Outputs
 - `before-version`: The version before running this action.
 - `after-version`: The version after running this action.
