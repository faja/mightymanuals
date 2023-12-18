- start server and listen on specific interface/port
    ```sh
    redis-server --bind *         --port 6379  # default
    redis-server --bind 127.0.0.1 --port 7777
    ```
- starting server with NO PROTECTED-MODE
    ```sh
    redis-server --protected-mode no
    ```
