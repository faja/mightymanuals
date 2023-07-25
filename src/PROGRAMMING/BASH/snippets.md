- read: yes/no/continue...
    ```sh
    echo -n "do something? [Y/n]: "
    read -r ANSWER
    if test "${ANSWER}" == "Y" \
      || test "${ANSWER}" == "y" \
      || test "${ANSWER}" == "Yes" \
      || test "${ANSWER}" == "yes" \
      || test -z "${ANSWER}"; then
      echo yes
    else
      echo skipping...
    fi
    ```

- read: ctrl+c or continue
    ```sh
    echo -n "do something? CTRL+C to stop, ENTER to continue: "
    read -r
    ```

- quickly check if var is set
    ```sh
    test "${XYZ:?}"  # exits 1 if XYZ is not set
    : "${XYZ2:?}"    # same as test, I think `test` is more elegant
      # actually I don't know, kinda like `:`
    test "${XYZ3:?"or with custom error message"}" # default message is
      # parameter null or not set
    ```
