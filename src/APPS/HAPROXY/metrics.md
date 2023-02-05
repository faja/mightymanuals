# 

HAProxy exposes ~ 185 uniq metrics.
We can divide them in 4 categories:
- `haproxy_process_` - related to the haproxy process itself
- `haproxy_frontend_` - haproxy frontend concept related stuff
- `haproxy_backend_` - haproxy backend concept related stuff
- `haproxy_server_` - haproxy server concept related sutff


# process
- haproxy_process_uptime_seconds  - gauge - uptime
- haproxy_process_nbproc          - gauge - number of threads
- haproxy_process_nbthread        - gauge - number of processes
- haproxy_process_current_tasks   - gauge - number of tasks in the current worker process (active + sleeping)

- haproxy_process_max_connections     - gauge   - limit on the number of per-process connections
- haproxy_process_current_connections - gauge   - current number of connections                            - this should give the same as sum(haproxy_frontend_current_sessions)
- haproxy_process_connections_total   - counter - total number of connections

- haproxy_process_requests_total - counter - total number of requests on this worker process

- haproxy_process_idle_time_percent - gauge - percentage of last second spent waiting in the current worker thread - we can get from this metric how BUSY the haproxy is, 100 - value = % busy

- haproxy_process_failed_resolutions - counter - total number of failed DNS resolutions
- haproxy_process_build_info         - gauge   - we can get version of haproxy from this metric

# frontend
- haproxy_frontend_current_sessions - gauge   - number of current sessions (PER FRONTEND) - sum of it should give the same value as haproxy_process_current_connections
- haproxy_frontend_limit_sessions   - gauge   - sessions limit (PER FRONTED), maxconn config option
- haproxy_frontend_sessions_total   - counter - sessions (PER FRONTED)

- haproxy_frontend_bytes_in_total  - counter - request bytes
- haproxy_frontend_bytes_out_total - counter - response bytes

- haproxy_frontend_request_errors_total - counter - number of invalid requests

- haproxy_frontend_http_responses_total - counter - HTTP responses (PER FRONTEND, PER CODE) (http mode frontends only, not including tcp mode frontends)
- haproxy_frontend_http_requests_total  - counter - HTTP requests  (PER FRONTEND)           (http mode frontends only, not including tcp mode frontends)

- haproxy_frontend_connections_total - counter - total number of connections

# backend
haproxy_backend_current_sessions - gauge - number of current sessions (PER BACKEND)
haproxy_backend_sessions_total   - counter - (PER BACKEND)

haproxy_backend_bytes_in_total
haproxy_backend_bytes_out_total

haproxy_backend_connection_errors_total - failed connections to backend server (PER BACKEND)

haproxy_backend_status - gauge - backend server current status (PER BACKEND)
haproxy_backend_active_servers - gauge - number of active (UP) bakend servers (PER BACKEND)
haproxy_backend_check_last_change_seconds - gauge - last time backend changed its state (PER BACKEND)

haproxy_backend_downtime_seconds_total - counter - total time spent in DOWN state (PER BACKEND)

haproxy_backend_loadbalanced_total - * - counter - total number of requests routed (PER BACKEND)        - mode tcp
haproxy_backend_http_responses_total - counter - total number of http responses (PER BACKEND, PER CODE) - mode http

haproxy_backend_http_requests_total - counter - total number of requests (PER BACKEND) - mode http
haproxy_backend_response_time_average_seconds - gauge - avg (last 1024 connections) response time


# server
haproxy_server_status - gauge - status of the server (PER BACKEND, PER SERVER, PER STATE)

haproxy_server_current_sessions - gauge - current sessions (PER BACKEND)
haproxy_server_sessions_total   - counter - sessions (PER BACKEND)

haproxy_server_bytes_in_total - counter
haproxy_server_bytes_out_total - counter 


haproxy_server_connection_errors_total - counter - Total number of failed connections to server (PER BACKEND, PER SERVER)

haproxy_server_check_failures_total      - counter - number of failed checks (PER BACKEND, PER SERVER)
haproxy_server_check_last_change_seconds - gauge - last time STATE of the server has changed (PER BACKEND, PER SERVER)
haproxy_server_downtime_seconds_total - counter - total time spent in DOWN state (PER BACKEND, PER SERVER)

haproxy_server_loadbalanced_total     - counter - number of requests routed by load balancing - I belivie thie is for HTTP and TCP modes

haproxy_server_check_code             - gauge - status code of the last check (per BACKEND, per SERVER)
haproxy_server_check_duration_seconds - gauge - duration of the last check (per BACKEND, PER SERVER)

haproxy_server_http_responses_total - counter - resonses (PER BACKEND, PER SERVER, PER CODE)
haproxy_server_response_time_average_seconds - gauge - avg (last 1024 connections) response time (PER BACKEND, PER SERVER)
haproxy_server_used_connections_current - gauge - Current number of connections in use (PER BACKEND, PER SERVER)



---
# process
haproxy_process_uptime_seconds  - gauge - uptime
haproxy_process_nbproc          - gauge - number of processes
haproxy_process_nbthread        - gauge - number of threads

haproxy_process_max_connections                                       - limit on the number of per-process connections
haproxy_process_connections_total{ingress="ingress-frontend-green"}   - connections/s
haproxy_process_current_connections{ingress="ingress-frontend-green"} - current connections

haproxy_process_idle_time_percent - gauge - percentage of last second spent waiting in the current worker thread - we can get from this metric how BUSY the haproxy is, 100 - value = % busy
haproxy_process_failed_resolutions - counter - total number of failed DNS resolutions

haproxy_process_build_info         - gauge   - we can get version of haproxy from this metric

# frontend


NOTES:
- loadbalanced_total == http_requests_total - if we have only http frontend, that means loadbalanced includes tcp + http

- connection vs session:
    - on the frontend, connection and session is pretty much the same, a client is connecting (TCP) to a frontend haproxy listener, and establises a session (HTTP)
    - on backend on the other hand, connection is when haproxy connects to a backend (TCP), and a session is HTTP session (that can go over the same TCP connection), hence
        haproxy_backend_sessions_total = haproxy_backend_connection_attempts_total + haproxy_backend_connection_reuses_total
