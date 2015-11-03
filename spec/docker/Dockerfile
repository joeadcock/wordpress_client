FROM appcontainers/wordpress

# base image only contains American timezones
RUN yum install -y tzdata

ENV APP_NAME testapp.com
ENV APACHE_SVRALIAS www.testapp.com localhost
ENV MYSQL_SERVER localhost
ENV MYSQL_CLIENT localhost
ENV MYSQL_PASS P@ssw0rd
ENV MYSQL_DB testapp
ENV APP_USER admin
ENV APP_PASS P@ssw0rd
ENV WP_KEY ILoveFlappyjacks

# Restore a copy of a set up database on first boot
COPY dbdump.sql.gz /tmp/dbdump.sql.gz
COPY restore-dbdump.sh /tmp/.restore-dbdump.sh
RUN chmod +x /tmp/.restore-dbdump.sh && \
    echo "if [ -f /tmp/.restore-dbdump.sh ]; then /tmp/.restore-dbdump.sh; rm -fr /tmp/.restore-dbdump.sh; fi" >> /root/.bashrc
