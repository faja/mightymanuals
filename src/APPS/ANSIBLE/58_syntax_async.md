---
- allows to start "next" task withouth waiting to finish the current one
- also, allows to avoid task execution exceeds timeout

```yaml
- name: clone really large git repo
  git:
    repo: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
    dest: /home/vagrant/linux
  async: 3600                     # async should take no longer than 3600s
  poll: 0                         # move immidiately to the next task, (wait 0 seconds)
                                  # non 0 value, means, check async task status every
                                  # "poll" value
  register: linux_clone           # you have to register the results

- name: do some other stuff in the meantime
  ...

- name: wait for linux clone to complete
  async_status:
    jid: "{{ linux_clone.ansible_job_id }}"  # check the async job status
  register: result
  until: result.finished # `async_status` module pulls only once, so we have to
                         # tell it to retry until the job completes
  retries: 3600
```
