FROM debian:trixie

RUN apt update \
 && apt upgrade -y \
 && apt install -y postgresql-client-16 sftp

COPY export.sh /export.sh

RUN chmod ugo+x /export.sh

ENTRYPOINT ["export.sh"]