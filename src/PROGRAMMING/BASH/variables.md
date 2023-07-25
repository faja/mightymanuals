# ${..inside..} manipulation

- `${..#..}` remove SHORTEST possible match from the BEGINNING
    ```sh
    FILE_NAME=/home/xyzzy/bin/my_script.sh
    echo ${FILE_NAME#/*/}    # => xyzzy/bin/my_script.sh
    echo ${FILE_NAME#*bin/}  # => my_script.sh
    # note! /../ is not regex, / is just normal character here we wanna match
    ```

- `${..##..}` remove LONGEST possible match from the BEGINNING
    ```sh
    FILE_NAME=/home/xyzzy/bin/my_script.sh
    echo ${FILE_NAME##/*/}    # => my_script.sh
    ```

- `${..%..}` remove SHORTEST possible match from the END
    ```sh
    FILE_NAME=/home/xyzzy/bin/my_script.sh
    echo ${FILE_NAME%/*.sh}  # => /home/xyzzy/bin
    ```

- `${..%%..}` remove LONGEST possible match from the END
    ```sh
    FILE_NAME=/home/xyzzy/bin/my_script.sh
    echo ${FILE_NAME%%/x*.sh}  # => /home
    echo ${FILE_NAME%%/*.sh}   # => "", empty string, it deletes the whole var
    ```

- `${..//}` substitue
    ```sh
    JOB=my-job-oh-yeah
    echo ${JOB/-/_}   # => my_job-oh-yeah
    echo ${JOB//-/_}  # => my_job_oh_yeah
    ```

- `${..::..}` shorten a string
    ```sh
    H=67407513080fa0a95f9b31496436b212167f9e18
    echo ${H}     # => 67407513080fa0a95f9b31496436b212167f9e18
    echo ${H::7}  # => 6740751
    ```

- `${#..}` number of characters
    ```sh
    X=123xxx
    Y=
    echo ${#H}  # => 6
    echo ${#Y}  # => 0
    ```
# ${...:...} variable default value, setting, error message...

- `${XYZ:-value}` - insert only
- `${XYZ:=value}` - insert and INITIALISE, see the difference:
    ```sh
    : ${XYZ:-ok}
    echo ${XYZ}  # => empty result

    : ${XYZ:=ok}
    echo ${XYZ}  # => ok
    ```

- `${XYZ:+value}` - if the var is unset, it will keep unset, if it is set to
  any value, it will be replaced with `value`
    ```sh
    XYZ=
    echo ${XYZ:+value}  # => empty result
    XYZ=blabla
    echo ${XYZ:+value}  # => value
    ```

- `${XYZ:?custom error message}` (or just `${XYZ:?}`) - checks if var is set,
  if not default/custom error message is printed and exit 1
    ```sh
    test "${XYZ:?}"  # exits 1 if XYZ is not set
    : "${XYZ2:?}"    # same as test, I think `test` is more elegant
    test "${XYZ3:?"or with custom error message"}"
    ```

# ${} built in vars

```sh
${0}  # name of the script
${?}  # exit status
${$}  # pid
${!}  # pid of the last executed program in the background

# ---------------------------------------------------------------------------- #

${#}  # number of arguments, eg

    while test "${#}" -ne 0; do
        echo "${1}"; shift
    done

# ---------------------------------------------------------------------------- #

${*}  # all arguments as a single argument, $* = "$1 $2 $3 ..."
${@}  # all arguments as it was passed,     $@ = "$1" "$2" "$3"

    # tip, play with
    set -- myarg1 "myarg2 oh still2" arg3 # this will set $1 $2 $3
    echo $1
    echo $2
    echo $3
    for i in "$*"; do echo $i; echo ---; done
    for i in $*; do echo $i; echo ---; done
    for i in "$@"; do echo $i; echo ---; done
    for i in $@; do echo $i; echo ---; done
```
