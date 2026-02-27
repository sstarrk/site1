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

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN useradd -m alnur && \
    echo "alnur:qwe123" | chpasswd

RUN ssh-keygen -A && \
    sed -i 's/#Port 22/Port 422/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /usr/share/nginx/html

COPY . .

EXPOSE 80 443 422

CMD ["/bin/bash", "-c", "/usr/sbin/sshd && nginx -g 'daemon off;'"]