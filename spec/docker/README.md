# Docker image for WordpressClient

Use this docker image to run integration tests, either in this repo or in some client repo where you use the gem.

**Note:** This image is not meant for *any* production use. It's meant for integration tests, and nothing else.

## Usage

You need to publish the container's port 80 to whichever port you want your instance on, then set an environment variable for where the server should be accessible from as Wordpress needs to have this stored in the database.

You also need to run it with an interactive terminal in order for it to work.

```bash
docker run -dit -p 8080:80 -e WORDPRESS_HOST=localhost:8080 hemnet/wordpress_client_test:latest
```

I you want to see the ouput or access the environment in order to debug an issue, omit the `-d` option. It will boot into a `bash` shell with Apache running in the background. You can also use `docker attach` to attach to a running instance.

**Note:** When you exit a running container, everything stored in it will be kept on disk. It is recommended that you `docker rm` the image when you are done to clean up.

When the instance is up and running, you can log in as an administrator using `test`/`test` as username and password.

## Contents

This image is based on Appcontainer's Wordpress image, which runs Apache, MySQL and PHP5 on CentOS using bash. In addition, a DB dump is restored containing a set up blog so you don't need to do the first installation steps.

* Username `test`
* Password `test`
* Plugin `WP-API` is installed
* Plugin `Basic-Auth` for `WP-API` installed
* `.htaccess` for Pretty Permalinks is set up so the API works

## Developing the image

### Re-creating DB dump from scratch

If you need to regenerate the DB dump, remove the part where the file is copied and restored from the `Dockerfile`, then build and start the image.

```bash
docker build -t wordpress_client_test:dev .
docker run -it -p 8181:80 wordpress_client_test:dev
```

You'll get a `bash` shell inside the container. Open your browser and go to the newly booted application (`localhost:8181` if you have native Docker; otherwise go to your `DOCKER_HOST_IP:8181` URL – see `echo $DOCKER_HOST` in your local shell).

You'll be greeted by the Wordpress installer. Fill in everything and complete the installation.

Then, **in your container's terminal**, run the following command:

```bash
mysqldump -u "$MYSQL_USER" --password="$MYSQL_PASS" --host="$MYSQL_HOST" "$MYSQL_DB" | gzip -9 > /tmp/dbdump.sql.gz
```

You can then copy the file to your host using the `docker cp` command:

```bash
docker ps | grep wordpress_client_test:dev
# See the container ID or name of your running container
docker cp THE-CONTAINER-ID:/tmp/dbdump.sql.gz .
```

Last step is to update `restore-dbdump.sh` to replace the hard-coded `WORDPRESS_HOST` placeholder with the one you used to generate the DB dump with. This corresponds with `localhost:8181` with native Docker if you followed these commands exactly. If you use `docker-machine`, you need to use your machine IP instead. (See *"Usage"* above)

You can then shut down your container by logging out of the container terminal. Restore the DB loading code from the `Dockerfile`, commit this file to the repo and rebuild everything and verify that Wordpress is still set up correctly when the dump is restored.
