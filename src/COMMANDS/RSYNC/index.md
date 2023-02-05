# rsync

## options
```bash
-a --delete                      # that's all you need
-a --delete --progress --stats   # to have some nice stats


-a, --archive       - archive mode = -rlptgoD
-r, --recursive     - recursive direcotires
-l, --links         - copy symlinks as symlinks
-p, --perms         - preserve permissions
-t, --times         - preserve modification times
-g, --group         - preserve group
-o, --owner         - preserve owner
-D                  - preserve devices and specials

-z --compress      - compress during transfer
```

## examples
- simple one liners
```bash
rsync -a --progress --stats --delete /airflow/ /opt/airflow/dags/

rsync -a --delete ~/.config/nvim/ nvim/  # sync local directory into other one
rsync -a --delete ~/.config/nvim/ .      # same, but if we are inside a directory we want to sync INTO
```

- backup from and to a server

```bash
#!/bin/sh
echo "Merging /home/sites from server";
/usr/bin/rsync -avzH -e ssh --stats --progress --numeric-ids \
                --update \
                --exclude-from /usr/local/backup/conf/in.exclude \
                alpha-complex.com:/home/sites/ /usr/local/backup/home/sites
echo "Done.";
```
```bash
#!/bin/sh
echo "Transfering /home/sites to server";
/usr/bin/rsync -avzH -e ssh --stats --progress --numeric-ids \
  --update \
  --cvs-exclude \
  --exclude-from /usr/local/backup/conf/in.exclude \
  --exclude-from /usr/local/backup/conf/out.exclude \
  /usr/local/backup/home/sites/ alpha-complex.com:/home/sites
echo "Done.";
```
