# users and roles in postgres

---

## tldr
on postgres RDS instance create a user for an app

```yaml
# connect to rds as master user usually user: `postgres` db: `postgres`
postgres=> CREATE ROLE ${name} LOGIN PASSWORD '${password}';
# make master member of ${name} role, this is needed to handover schema ownership later on
postgres=> GRANT ${name} TO current_user;
postgres=> CREATE DATABASE ${name} TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C';
postgres=> REVOKE ALL ON DATABASE ${name} FROM PUBLIC;
  # note: PUBLIC is a pseudo-role meaning "everyone",
  # this commands is basicaly "noone can use this DB just yet"
postgres=> GRANT CONNECT, TEMPORARY ON DATABASE ${name} TO ${name};
  # note: there is no CREATE permission, app won't be able to create SCHEMAS,
  # master user gonna do it in the next step


# connect to created DB
postgres=> \c {name}
# create a schema and set the owner to ${name}
${name}=>  CREATE SCHEMA ${name} AUTHORIZATION ${name};
  # note: AUTHORIZATION sets the ownership,
  # an owner grants CREATE + USAGE on the schema automagically
${name}=>  ALTER ROLE ${name} IN DATABASE ${name} SET search_path = ${name};


# verify
=> \dn   -- list schemas in ${name}
=> \du+  -- list roles
=> \l+   -- list databases and owners
```

the idea is to:
- master user owns the database
- app user can NOT create schemas
- master user creates a schema but grants ownership for it to app user
- app user can create tables and manages DDL

---

## details

- in postgres there is only a concept of `ROLE`s - there is no such thing as "user"
- in practice: `ROLE` with `LOGIN` propery is a "user", and `ROLE` without `LOGIN` is a "group"
- a `ROLE` is cluster-wide concept

```yaml
=> \du+                           # list roles/usernames
=> SELECT rolname FROM pg_roles;  # list all roles (login and no login)
```

```yaml
=> CREATE ROLE ${name} NOLOGIN;                  # create a "group"
=> CREATE ROLE ${name} LOGIN PASSWORD 'string';  # create a "user"
# in general syntax is "CREATE ROLE ${name} ${PROPERTIES...}
# and the properties can be: LOGIN, NOLOGIN, SUPERUSER, CREATEDB, CREATEROLE, INHERIT(default)
# google/chat for more details


=> ALTER ROLE ${name} CREATEDB;
=> DROP ROLE name;


=> GRANT ${group_name} TO ${user_name};     # add a user to a group
=> GRANT ${group_name} TO current_user;     # add current user to a group
=> REVOKE ${group_name} FROM ${user_name};  # remove a user from a group


=> ALTER ROLE ${name} WITH PASSWORD 'new_pass';  # update password
```

### privileges
```yaml
rolename=xxxx -- privileges granted to a role
        =xxxx -- privileges granted to PUBLIC

            r -- SELECT ("read")
            w -- UPDATE ("write")
            a -- INSERT ("append")
            d -- DELETE
            D -- TRUNCATE
            x -- REFERENCES
            t -- TRIGGER
            X -- EXECUTE
            U -- USAGE
            C -- CREATE
            c -- CONNECT
            T -- TEMPORARY
      arwdDxt -- ALL PRIVILEGES (for tables, varies for other objects)
            * -- grant option for preceding privilege

        /yyyy -- role that granted this privilege
```
