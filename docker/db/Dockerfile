FROM couchdb:2.3.1

EXPOSE 5984 6984 9100

COPY local.ini /opt/couchdb/etc/local.ini
COPY couch_ca.crt /opt/couchdb/etc/couch_ca.crt
COPY db-init.sh /usr/local/bin/db-init.sh
COPY entrypoint /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["couchdb"]
