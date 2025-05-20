---
[community.docker](https://docs.ansible.com/ansible/latest/collections/community/docker/index.html) collection

there is a buch of modules, plugin, etc, see docs for details,

some of the modules:

```
docker_login
docker_image
docker_container
docker_compose
```

---

### `docker_compose`
```yaml
- name: Pull an image
  become: true
  community.docker.docker_image_pull:
    name: "{{ prometheus_image_name }}"
    tag: "{{ prometheus_image_tag }}"
    pull: not_present

- name: Run `docker compose up`
  become: true
  community.docker.docker_compose_v2:
    project_src: /var/lib/docker-compose/prometheus
```

### handler: send signal
```yaml
- name: reload prometheus config
  become: true
  listen: prometheus_config_reload
  community.docker.docker_container:
    name: prometheus
    state: stopped    # send signal but don't remove container
    force_kill: true  # use kill signal instead of stop
    kill_signal: HUP  # send HUP instead of kill
```

### handler: restart container
```yaml
- name: restart grafana container
  become: true
  listen: grafana_container_restart
  community.docker.docker_container:
    name: grafana
    restart: yes
```
