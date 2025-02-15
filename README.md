# AWS Codebuild Github Runner Demo

`.github/workflow/` location for jobs.

- Requires Codestar Connection (hides under Settings->Connection in CodeBuild)
- Requires Authorized Connection in Connection (developer tools)
- Requires Established CodeBuild Runner for Github
- Requires you get your permissions right on CodeBuild for whatever this does in AWS
- Requires github action job for runs-on:

```yaml
name: Hello World
on: [push]
jobs:
  Hello-World-Job:
    runs-on:
      - codebuild-<your runner name>-${{ github.run_id }}-${{ github.run_attempt }}
    steps:
      - run: echo "Hello World"
```
