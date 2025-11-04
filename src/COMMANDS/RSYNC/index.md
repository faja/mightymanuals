# rsync

## options
```bash
# for local syncing
-a --delete                      # that's all you need
-a --delete --progress --stats   # to have some nice stats

# for ssh syncing
-avzH -e ssh --stats --progress

# options
-a, --archive       - archive mode = -rlptgoD
-r, --recursive     - recursive direcotires
-l, --links         - copy symlinks as symlinks
-p, --perms         - preserve permissions
-t, --times         - preserve modification times
-g, --group         - preserve group
-o, --owner         - preserve owner
-D                  - preserve devices and specials

-z --compress       - compress during transfer

--exclude 'pattern' - exclude files from being copied, eg: `--exclude '.git'`, `--exclude '*.log'`
```

## examples
- simple one liners
```sh
rsync -avzH -e ssh --stats --progress /var/lib/prometheus root@172.30.91.136:/var/lib/prometheus

rsync -a --progress --stats --delete /airflow/ /opt/airflow/dags/

rsync -a --delete ~/.config/nvim/ nvim/  # sync local directory into other one
rsync -a --delete ~/.config/nvim/ .      # same, but if we are inside a directory we want to sync INTO
```

- directory madness
```sh
# case 1, destination directory does not exist
# copy /var/lib/prometheus to /var/lib/prometheus (creates remote dir)
... /var/lib/prometheus root@172.30.91.136:/var/lib


# case 2a, destination directory does exist
#   in the example below /var/lib/prometheus EXISTS in the destination
... /var/lib/prometheus root@172.30.91.136:/var/lib

# case 2b, destination directory does exist
#   in the example below /var/lib/prometheus EXISTS in the destination
#   we explicitly say copy content of into the existing one
#   by using ending `/` - I PREFER this one!
... /var/lib/prometheus/ root@172.30.91.136:/var/lib/prometheus/
```
