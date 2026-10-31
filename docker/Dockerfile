FROM oraclelinux:8

# Install Oracle Instant Client and SQL*Plus
RUN dnf -y install oracle-instantclient-release-el8 && \
    dnf -y install oracle-instantclient-basic oracle-instantclient-sqlplus oracle-instantclient-tools && \
    dnf clean all

WORKDIR /data
COPY scripts/ /data/scripts/

ENTRYPOINT ["/bin/bash"]
