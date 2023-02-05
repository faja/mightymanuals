2022/11/27 09:29:12 [debug] 75#75: *1 trying to use file: "/a.html" "/etc/nginx/a.html"
2022/11/27 09:29:12 [debug] 75#75: *1 trying to use file: "blabla.html" "/etc/nginxblabla.html"
2022/11/27 09:29:12 [debug] 75#75: *1 trying to use file: "=404" "/etc/nginx=404"


2022/11/27 11:46:49 [debug] 138#138: *1 try files handler
2022/11/27 11:46:49 [debug] 138#138: *1 http script var: "/ip"
2022/11/27 11:46:49 [debug] 138#138: *1 trying to use file: "/ip" "/etc/nginx/ip"
2022/11/27 11:46:49 [debug] 138#138: *1 trying to use file: "/file1.html" "/etc/nginx/file1.html"
2022/11/27 11:46:49 [debug] 138#138: *1 trying to use file: "/file2.html" "/etc/nginx/file2.html"
2022/11/27 11:46:49 [debug] 138#138: *1 http script copy: "/dir1/"
2022/11/27 11:46:49 [debug] 138#138: *1 http script var: "/ip"
2022/11/27 11:46:49 [debug] 138#138: *1 trying to use file: "/dir1//ip" "/etc/nginx/dir1//ip"
2022/11/27 11:46:49 [debug] 138#138: *1 trying to use file: "@httpbin" "/etc/nginx@httpbin"
2022/11/27 11:46:49 [debug] 138#138: *1 test location: "@httpbin"
2022/11/27 11:46:49 [debug] 138#138: *1 using location: @httpbin "/ip?"
2022/11/27 11:46:49 [debug] 138#138: *1 rewrite phase: 3
2022/11/27 11:46:49 [debug] 138#138: *1 http script regex: "/httpbin/(.*)"
2022/11/27 11:46:49 [notice] 138#138: *1 "/httpbin/(.*)" does not match "/ip", client: 172.24.0.1, server: _, request: "GET /ip HTTP/1.1", host: "127.0.0.1:8080"
