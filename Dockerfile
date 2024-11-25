FROM debian:12

ENV SAMBA_VERSION=4.21.2
RUN apt-get update
RUN apt-get install wget -y
RUN mkdir ~/build \
 && cd ~/build \
 && wget --content-disposition https://download.samba.org/pub/samba/stable/samba-$SAMBA_VERSION.tar.gz
RUN cd ~/build \
 && tar xvfz samba-$SAMBA_VERSION.tar.gz
ENV LANG=en_US.UTF-8
RUN cd ~/build/samba-$SAMBA_VERSION/bootstrap/generated-dists/debian12 \
 && ./bootstrap.sh
RUN cd ~/build/samba-$SAMBA_VERSION \
 && ./configure \
    --libdir=/usr/lib64 \
    --prefix=/usr --exec-prefix=/usr --sysconfdir=/etc \
    --localstatedir=/var \
    --with-privatedir=/var/lib/samba/private \
    --with-smbpasswd-file=/etc/samba/smbpasswd \
    --enable-fhs \
 && make -j$(nproc) \
 && make install 
COPY initunixusers /initunixusers
COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint"]
CMD ["tail -F /var/log/samba/log*"]
