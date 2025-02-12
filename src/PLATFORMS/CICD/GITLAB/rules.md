- run on default branch and MRs only
```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH      # run on default branch
      when: always                                     # trigger AUTOMATICALLY
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event' # run on MRs
      when: manual                                     # trigger MANUALLY
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

- similar rules can be applied at the **JOB** level

- <span style="color:#ff4d94">**note:**</span>
    - workflow rules - specify when **PIPELINE** is created,
    - **JOB** rules specify when job is created/executed,
      there is NO interaction between these two
