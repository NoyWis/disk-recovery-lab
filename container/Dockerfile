FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
        util-linux \
        e2fsprogs \
        xfsprogs \
        dosfstools \
        parted \
        gdisk \
        lvm2 \
        nano \
        vim \
        less \
        man-db \
        sudo \
        iproute2 \
        procps \
        tree \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd \
    && useradd -m -s /bin/bash -G sudo student \
    && echo 'student:student' | chpasswd \
    && echo 'root:root' | chpasswd \
    && echo 'student ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
