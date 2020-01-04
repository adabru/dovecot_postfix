FROM alpine
RUN apk add --no-cache postfix dovecot
# see man pages and the default config files for more configuration options
COPY postfix/master.cf /etc/postfix/master.cf
COPY postfix/main.cf /etc/postfix/main.cf
COPY postfix/aliases /etc/postfix/aliases

RUN newaliases
# default self signed tls certificate, use volume mounts to bind CA signed cert
RUN openssl req -x509 -nodes -days 365 -batch -newkey rsa:2048 -keyout /etc/ssl/private/mail.key -out /etc/ssl/certs/mailcert.pem

COPY dovecot.conf /etc/dovecot/dovecot.cf