FROM centos:8

COPY bootstrap.sh /bootstrap.sh
RUN sh /bootstrap.sh

ENV SAMBA_VERSION=4.14.6
RUN mkdir ~/build \
 && cd ~/build \
 && wget --content-disposition https://download.samba.org/pub/samba/stable/samba-$SAMBA_VERSION.tar.gz
RUN cd ~/build \
 && tar xvfz samba-$SAMBA_VERSION.tar.gz
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
