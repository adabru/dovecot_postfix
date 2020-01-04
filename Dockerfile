FROM alpine
RUN apk add --no-cache postfix dovecot
COPY postfix/master.cf /etc/postfix/master.cf
COPY postfix/main.cf /etc/postfix/main.cf
COPY dovecot.conf /etc/dovecot/dovecot.cf