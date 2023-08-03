- run on default branch and MRs only
```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH      # run on default branch
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event' # run on MRs
    - when: never                                      # do NOT run in any other case
```

- run on all commits, but skip commit pipeline if there is an MR pipeline
```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never                                      # do NOT run on commits if there is an MR opened
    - when: always                                     # run in any other case
```
