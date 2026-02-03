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

### workflow rules

```yaml
# case 1: MR pipelines

workflow:
  rules:
    - if: $CI_COMMIT_TAG                               # run on tags
    - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH    # run on default branch
    - if: $CI_PIPELINE_SOURCE == "merge_request_event" # run on MRs

# case 2: branch pipelines
workflow:
  rules:
    - if: $CI_COMMIT_TAG     # run on tags
    - if: $CI_COMMIT_BRANCH  # run on branches, (note: CI_COMMIT_BRANCH var is not set on MRs, hence a branch pipeline)
```

### job rules

#### examples
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

#### changes
Using changes, depends on if you go for MR or BRANCH pipelines
NOTE: on TAG pipelines - `changes` is always evaluated as `true`

```yaml
# case 1: MR pipelines and default branch - both if something changed
#         we don't need compare_to parameter

rules:
  - if: $CI_PIPELINE_SOURCE == "web" # run a job, if pipeline is triggered manually via UI, no matter if
                                     # this is nice, if we wanna use `changes` on default branch
  - changes:            # this rule gonna trigger a job, on MR and default branch
      paths:            # but only if code has been changed
        - deploy/**/*
  - when: never

# case 2: MR pipleine if changed, but default branch always
rules:
  - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    changes:            # this rule gonna trigger a job, on MR and default branch
      paths:            # but only if code has been changed
        - deploy/**/*
  - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH # but run on default branch, no matter if changed
  - when: never

# case 3: branch pipelines, both default and non default if changed
#         on branch pipelines we need to use compare_to

rules:
  - if: $CI_PIPELINE_SOURCE == "web" # run a job, if pipeline is triggered manually via UI, no matter if
                                     # this is nice, if we wanna use `changes` on default branch
  - if: $CI_COMMIT_REF_NAME != $CI_DEFAULT_BRANCH # run on a branch but only if changed
    changes:
      compare_to: refs/heads/$CI_DEFAULT_BRANCH
      paths:
        - deploy/**/*
  - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH # run on default branch if changed
    changes:
      paths:
        - deploy/**/*
  - when: never

# case 4: branch pipelines, non default if changed, default always
#         on branch pipelines we need to use compare_to

rules:
  - if: $CI_COMMIT_REF_NAME != $CI_DEFAULT_BRANCH # run on a branch but only if changed
    changes:
      compare_to: refs/heads/$CI_DEFAULT_BRANCH
      paths:
        - deploy/**/*
  - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH # run on default branch always
  - when: never

```
