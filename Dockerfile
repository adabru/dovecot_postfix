FROM alpine
RUN apk add --no-cache opensmtpd dovecot

# see man pages and the default config files for more configuration options
COPY opensmtpd.conf /etc/smtpd/smtpd.conf
COPY aliases /etc/smtpd/aliases
RUN makemap -d btree -t aliases /etc/smtpd/aliases
# default self signed tls certificate, use volume mounts to bind CA signed cert
RUN openssl req -x509 -nodes -days 365 -batch -newkey rsa:2048 -keyout /etc/ssl/private/mail.key -out /etc/ssl/certs/mailcert.pem

COPY dovecot.conf /etc/dovecot/dovecot.cf
