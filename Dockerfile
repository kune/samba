FROM centos:7

ENV SAMBA_VERSION=4.18.3
RUN curl  "https://git.samba.org/?p=samba.git;a=blob_plain;f=bootstrap/generated-dists/centos7/bootstrap.sh" > /bootstrap.sh
RUN sh /bootstrap.sh
RUN mkdir ~/build \
 && cd ~/build \
 && wget --content-disposition https://download.samba.org/pub/samba/stable/samba-$SAMBA_VERSION.tar.gz
RUN cd ~/build \
 && tar xvfz samba-$SAMBA_VERSION.tar.gz
ENV LANG=en_US.UTF-8
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
