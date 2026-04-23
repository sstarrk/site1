FROM centos:7

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo

    RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install nginx openssh-server openssh-clients openssl && \
    yum clean all


RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=KZ/ST=Astana/L=Astana/O=DevOps/CN=localhost"

RUN useradd -m alnur && \
    echo "alnur:qwe123" | chpasswd

RUN ssh-keygen -A && \
    sed -i 's/#Port 22/Port 422/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /usr/share/nginx/html

COPY . .

RUN mkdir -p /home/alnur/.ssh && \
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCctwoykrvPJZ3ZcgJHGhjs7Pa+2U9RJRU4+YpC8OMjHiaSlEGrNkFdPpkUw3UUf3EqfJzJqGFx7WY6BDz8SDLm5FBgJ3avELFRoyXY3quzwpMA2h1P47/jRGuKc9L50l7+w6948FpyBLhJeClN0vJxpDE4Wu95lmjwyuG9P0CbF59CUU3lvxEsOH3jSrIwXfnJk/P0R07sMkDvUMBF84ZgYd5v00yy60JSXfug5nn3SL2MJADXTWXcbvwPx/Cr9g6SlbETQiB6j/HR4G4DJpdLKqmnoX22WAUWN3eUyu0dxgADuhqyTO+yFfv2uQQ1Nsfv5PV4r8YZZu8amk0MKgZD alnur@testubuntu" >> /home/alnur/.ssh/authorized_keys && \
    chown -R alnur:alnur /home/alnur/.ssh && \
    chmod 700 /home/alnur/.ssh && \
    chmod 600 /home/alnur/.ssh/authorized_keys

RUN chown -R alnur:alnur /usr/share/nginx/html/

EXPOSE 80 443 422

CMD ["/bin/bash", "-c", "/usr/sbin/sshd && nginx -g 'daemon off;'"]
