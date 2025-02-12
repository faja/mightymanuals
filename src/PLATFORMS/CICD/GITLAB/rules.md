- <span style="color:#ff4d94">**note:**</span> `rules` can be applied on:
    - `workflow` level - which specify when **PIPELINE** is created,
        ```yaml
        workflow:
          rules:
            ...
        ```
    - `job` level - which specify when job is created/executed,
        ```yaml
        some_job_name:
          rules:
            ...
        ```
these do not interact between each other, even the syntax and keyword `rule`
is exactly the same


### examples
- run on default branch and MRs only
    ```yaml
    rules:
      - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH      # run on default branch
        when: always                                     # trigger AUTOMATICALLY
      - if: $CI_PIPELINE_SOURCE == 'merge_request_event' # run on MRs
        when: manual                                     # trigger MANUALLY
      - when: never                                      # do NOT run in any other case
    ```

- run on all commits, but skip commit pipeline if there is an MR pipeline
    ```yaml
    rules:
      - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
        when: never                                      # do NOT run on commits if there is an MR opened
      - when: always                                     # run in any other case
    ```

- NOTE! if `pipeline must succeed` setting is on, manual jobs, would block
  merge, to fix this, use `allow_failure: true`
    ```yaml
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event' # run on MRs
      when: manual                                     # trigger MANUALLY
      allow_failure: true # treat not executed manual job as `passed`
    ```
