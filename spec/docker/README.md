# How this was built

## dbdump

If you need to regenerate the dbdump, remove the part where the file is copied and restored from the `Dockerfile`, then build and start the image.

```bash
docker build -t wpclient-test .
docker run -it -p 8181:80 wpclient-test
```

You'll get a prompt inside the container. Open your browser and go to the newly booted application (`localhost:8181` if you have native Docker; otherwise go to your `$DOCKER_HOST_IP:8181` URL – see `echo $DOCKER_HOST` in your local shell).

You\ll be greeted by the Wordpress installer. Fill in everything and complete the installation.

Then, **in your container's terminal**, run the following command:

```bash
mysqldump -u "$MYSQL_USER" --password="$MYSQL_PASS" --host="$MYSQL_HOST" "$MYSQL_DB" | gzip > /tmp/dbdump.sql.gz
```

You can then copy the file to your host using the `docker cp` command:

```bash
docker ps | grep wpclient-test
# See the container ID or name of your running container
docker cp THE-CONTAINER-ID:/tmp/dmdump.sql.gz .
```

You can then shut down your container by logging out of the container terminal.

Restore the DB loading code from the `Dockerfile`, commit this file to the repo and rebuild everything and verify that Wordpress is still set up correctly when the dump is restored.
