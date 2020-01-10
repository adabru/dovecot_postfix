
# Status (dormant)

Google hosting doesn't allow port 25 no way, I guess all other hosts do allow.
Because of policy I am bound to google hosting for half a year.
After searching the web I didn't find a configuration for neither postfix nor opensmtpd to allow relaying to smtps 465.
This option probably won't be implemented in the future either, as smtps was deprecated by IANA, although it is more secure than 587/STARTTLS which can downgrade to plain text.
Furthermore port 465 is redefined as tls-implicit-submission, which makes it both better and worse.
With this situation I decided to use an external smtp relay while I am bound to google. After that period I will reconsider.

TODOs:

- openrelay check: http://www.mailradar.com/openrelay/
- antispam greylist: https://www.heinlein-support.de/sites/default/files/SPF-DKIM-Greylisting_FrOSCon_2012.pdf

## Incomplete Setup

Run

```
git clone https://github.com/adabru/dovecot_postfix.git
cd dovecot_postfix
docker build -t mail .
# if apk install fails try: (see https://github.com/gliderlabs/docker-alpine/issues/386#issuecomment-567684492)
# docker build -t mail --network=host .

# get inside the container:
docker run --rm --name test -ti -p 465:465 -p 993:993 -e DOMAIN=yourdomain.com -e MYNETWORKS="127.0.0.0/8, 172.17.0.0/16" mail /bin/sh
```

```
# test global connectivity in both directions
ping adabru.de
nc -v -l -p 465

# change your domain
sed -i "s/example\.com/$DOMAIN/" /etc/smtpd/smtpd.conf
# add local trusted networks
sed -i "s|127\.0\.0\.0/8|$MYNETWORKS|" /etc/smtpd/smtpd.conf

syslogd
smtpd

# check logs
tail /var/log/messages

# start a new terminal
```

```
DOMAIN=yourdomain.com
RECIPIENT=info@someotherdomain.com

# check connection
nc $DOMAIN 465

# check smtps service
msmtp -v --host=$DOMAIN --port=465 --tls=on --tls-starttls=off --tls-certcheck=off -S

# send email to yourself
echo -e "Subject: Hello\n\nWorld!" | \
msmtp -v --host=$DOMAIN --port=465 --tls=on --tls-starttls=off  --tls-certcheck=off --auth=off \
  --from=info@$DOMAIN --add-missing-from-header=on --add-missing-date-header=on \
  -- info@$DOMAIN

# send email to another server (must be run from same host)
echo -e "Subject: Hello\n\nWorld!" | \
msmtp -v --host=localhost --port=465 --tls=on --tls-starttls=off  --tls-certcheck=off --auth=off \
  --from=info@$DOMAIN --add-missing-from-header=on --add-missing-date-header=on \
  -- $RECIPIENT
```
