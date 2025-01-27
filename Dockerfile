FROM registry.access.redhat.com/ubi9/ubi-init

ENV SNGRPM="syslog-ng-premium-edition-8.0.0-1+20250116+1752.rhel9.x86_64.rpm"

ADD $SNGRPM /

# install syslog-ng and disable rsyslog
RUN dnf clean all -y && \
    dnf update -y && \
    dnf remove -y rsyslog && \
    dnf install -y /$SNGRPM && \
    dnf clean all -y && \
    rm /$SNGRPM

#add a slightly modified syslog-ng configuration
ADD syslog-ng.conf /opt/syslog-ng/etc/

# add files related to the syslog-ng Prometheus exporter
ADD sng_exporter.py /usr/local/bin/
ADD sngexporter.service /usr/lib/systemd/system/
ADD sngexporter /etc/sysconfig

# enable syslog-ng in systemd
RUN systemctl enable syslog-ng
# syslog-ng-wec sngexporter

# expose ports
# rfc3164
EXPOSE 514
# rfc5424
EXPOSE 601
# rfc5414 + TLS (does not work out of the box)
EXPOSE 6514
# syslog-ng Prometheus exporter
EXPOSE 9577
# ALTP
EXPOSE 35514

# start systemd, which starts syslog-ng
CMD ["/sbin/init"]
