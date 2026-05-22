```Dockerfile
# 安装 SSH
RUN apt update && apt install -y openssh-server && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo 'root:1121' | chpasswd
```

`service ssh start`