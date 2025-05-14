---

filters allow manipulate a variable in a certain way, eg:
```yaml
{{ var_that_is_a_list | first() }}
```

- jinja2 build in filters - [list](https://tedboy.github.io/jinja2/templ14.html)
- ansible filters - [list](https://docs.ansible.com/ansible/latest/collections/index_filter.html)

---

- [custom filters](#custom-filters)

---

FILTERS:

- [basename|dirname|expanduser|realpath](#basename-dirname-expanduser-realpath)
- [default](#default)
- [failed|changed|success|skipped](#failed-changed-success-skipped)


### basename dirname expanduser realpath
these are filepaths related filters, pretty much selfexplanatory
- `basename` - base name of filepath
- `dirname` - directory of filepath
- `expanduser` - filepath with `~` repaced
- `realpath` - canonical path of filepath, resolves symbolic links

### default

```yaml
{{ var_that_doesnt_exist | default("lesssgo") }}
```

### failed changed success skipped
these can be used with `register` to check state of the previous task result
```yaml
- name:
  ...
  ignore_errors: true
  register: result

- debug: var=result

- debug:
    msg: stop running if previous task failed
  failed_when: result|failed
```

---

# custom filters
- you can create custom filters
- ansible will look for custom filters in
  - `filter_plugins` in your playbook directory
  - `~/.ansible/plugins/filter`
  - `/usr/share/ansible/plugins/filter`
  - location specified by `ANSIBLE_FILTER_PLUGINS`
