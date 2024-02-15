# EXAMPLES, TLDR

## ...


## Step by step how to move a database from RDS to docker compose based postgres

1. STEP1: current DB check up
    Connect to existing DB and check the "OWNER" configuration
	```sh
    % psql ...
	> \l+         # list all DB and OWNER
	> \c portus
	> \dn+        # list schemas and OWNER
	> \d+
	```
	If needed adjust the OWNER
	```sh
    > \c portus
	> ALTER DATABASE portus OWNER TO portus;
    > ALTER SCHEMA public OWNER TO portus;
    > \dn+
    > REVOKE ALL ON SCHEMA public FROM PUBLIC;
	```


2. STEP2: new DB prep work
    Create docker compose volume and service, the below is just an example
    that should work, but please adjust for your needs
    ```yaml
    ---
    volumes:
      dbdata:

    services:
      db:
        image: postgres:11.22-alpine
        environment:
          - POSTGRES_PASSWORD=root  # please adjust
          - POSTGRES_USER=root      # please adjust
        volumes:
          - dbdata:/var/lib/postgresql/data  # IMPORTANT! can't be /var/lib/postgresql!
          - ./dumps:/dumps                   # please remove once restore is complete
    ```
    ```sh
    % docker compose up -d
    % docker compose exec db bash
    ```
    ```sh
    % psql
    > CREATE ROLE portus LOGIN INHERIT PASSWORD '__OLD__PASSWORD__';
    > CREATE DATABASE portus OWNER portus;
    > \c portus
    > ALTER SCHEMA public OWNER TO portus;
    > REVOKE ALL ON SCHEMA public FROM PUBLIC;
    ```

3. STEP3: the dump
    Stop all process first and make sure there are no connections to the DB
    ```sh
    > SELECT count(datname) FROM pg_stat_activity WHERE datname='portus';
    ```
    DO the dump
    ```sh
    % pg_dump -h ....rds.amazonaws.com -U portus -d portus -f /dumps/portus.$(date -u +%Y.%m.%d).sql
    % grep -e REVOKE -e GRANT /dumps/portus.$(date -u +%Y.%m.%d).sql
    ```
4. STEP4: the restore
    In the db container
    ```sh
    % psql -X -q -1 -v ON_ERROR_STOP=1 \
      -U portus -d portus \
      -f /dumps/portus.$(date -u +%Y.%m.%d).sql \
      -L /dumps/portus.$(date -u +%Y.%m.%d).restore.log
        # -X : do not read .psql config files
        # -q : run it quietly
        # -1 : single transaction
        # -v ON_ERROR_STOP=1 : stops in case of any error

    # or yolo version
    % psql -U portus -d portus -f /dumps/portus.$(date -u +%Y.%m.%d).sql
    ```
5. STEP5: reconfigure db address and start services
