# FSI Server Container Setup

(valid until version 22.x)

![alt text](http://fsi-site.neptunelabs.com/fsi/server?type=image&source=images%2Ffsi-logos%2Ffsi_server.png&width=250&height=86&format=png "FSI Server Logo")

---

## What is FSI Server?

FSI Server dynamically generates images in a variety of formats, sizes and qualities - in real time.
You only need to upload one high-resolution source image for each image used on a website,
eliminating costly and time-consuming manual image preparation.
Variations are retrieved by a web application directly from FSI Server using HTTP queries.
FSI Server provides a comprehensive set of HTTP commands that allow full control over the image data delivered.

In addition, the FSI Server comes with a variety of viewers that make integration 
into existing websites very easy.


## Requirements

From version 16 FSI Server is available as a pre-configured container.
This allows setting up the software on many more platforms,
reduces the setup efforts to a minimum and enables software updates with very little downtime.

Users of FSI Server with Tomcat/WAR (*Web Application Archive*)
installations are strongly advised to upgrade to the container version.

Containers are currently shipped for x86-64 architectures.

At least 2 GB of RAM per CPU thread and a total amount of 8 GB RAM are recommended.
For production environments with millions of images, systems with more than 32GB of RAM are recommended.
Monitor the log output to identify any bottlenecks.

## How to use this repository

This repository contains a *docker-compose* file for **Docker** or **Podman** version 3.0 or higher.

Depending on the version, perform typical start/stop as follows.

``` shell
docker compose up --build -d
```

``` shell
docker compose down
```

If you are new to **docker** or **docker compose** commands, you might want to read the
[documentation](https://docs.docker.com/compose/) first.

### *docker-compose.yml and .env*

This repository comes with a `docker-compose.yml` file that contains **Apache Solr** for internal search,
[nginx](https://nginx.org/) for SSL termination and [lsyncd](https://github.com/lsyncd/lsyncd) for synchronisation.
You are free to replace nginx with your own preferred SSL termination server,
such as [Caddy](https://caddyserver.com/), [Traefik](https://traefik.io/)
or [Hitch](https://www.varnish-software.com/community/hitch/).

It also contains invalid, but necessary for a first start, SSL certificates for localhost.
You should replace them with valid certificates for your domain for production purposes.

The `docker-compose.yml` contains variable assignments from the file `.env`. Please adjust the file according
to your needs, i.e. the path for the source files and the storage, the configuration, etc.
The variables mean:

| VARIABLE             | MEANING                                                                |
|----------------------|------------------------------------------------------------------------|
| FSI_SERVER_IMAGE     | the name of the image (please leave this untouched)                    |
| FSI_SERVER_IMAGE_TAG | the version you want to use or can use (depending on the licence)      |
| NGINX_IMAGE_TAG      | Docker version tag for the nginx container                             |
| FSI_CONFIG_PATH      | path in your filesystem for the configuration                          |
| NGINX_CONFIG_PATH    | path to the nginx configuration and certificated                       |
| ASSET_PATH           | path in your filesystem for all your images                            |
| STORAGE_PATH         | path in your filesystem for all images optimised for real-time scaling |
| OVERLAY_PATH         | config folder for all FSI Viewer settings                              |
| SYNC_KEY             | path to the lsyncd private key                                         |
| MIRROR_HOSTNAME      | domain name or IP of the mirror server                                 |
| LOG_LEVEL            | log output verbosity                                                   |

### Directory - _conf_

This directory contains all important configurations for the FSI server, but also for nginx or lsyncd.

### Directory - _fsi-server_

The entire configuration of the FSI server is located here.
Docker needs write access to this directory.

### Directory - _fsi-data_

This directory contains the so-called `storage`, which contains optimised versions of the asset.
It also contains **Apache Solr**'s search database, **Apache Tomcat Server**'s temporary files
and a directory for FSI Viewer configurations (overlay).

This demo repository also contains the `assets/images` directory,
in which all images for the *connector* `images.yml` must be located.

Docker needs write access to this directory.

### Where to put my pictures?

For test purposes, you can store your images under `fsi-data/assets/images`.
For production environments, place the images where it is best for backup and synchronisation tasks.
Then create connectors under `conf/fsi-server/connectors`, according to the mappings in the `docker-compose.yml`.

### *kubernetes*

Apart from docker or Podman, you can also run the containers in a k8s environment.
The important thing here is access to the assets and the storage.
These should be connected as efficiently as possible.
In the case of k8s, this may include atypical local storage.

If you connect an S3 storage via e.g. [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse)
or [mountpoint](https://github.com/awslabs/mountpoint-s3),
we recommend benchmarks (see below) for filling with images and retrieving them before going live.


## Synchronisation to mirror servers with *lsyncd*

If you do not operate a second, third or further mirror server,
you can ignore all information in this section.

However, if you want to run more than one Image Server with the same assets,
you not only need to synchronise the images between the servers,
but also new asset metadata and viewer configurations.
Depending on your setup, you may also want to synchronise the server configuration.

If you are not using a distributed file system, **lsyncd** can be used as a synchronisation tool.
**Lsyncd** is reliable and proven, and allows very complex settings through Lua script-based configuration.

### Config changes

This is based on the `docker-compose-with-mirror.yml` compose file, which also provides a lsyncd service.

On the target systems, **ssh** and **rsync** are required.

An SSH Key is used to authenticate.
The configuration of the lsyncd daemon are provided in the `conf/lsyncd` directory.

For production use, you will need to change `MIRROR_HOSTNAME` for the
remote server in `.env`.
The paths should be in the same place,
otherwise the file `conf/lsyncd/lsyncd.conf.lua` must be adapted accordingly,
e.g. like this:

```lua
sync {
  target = "fsi-secondary.domain.tld:/data/fsi-data/overlay",
}
```

If necessary, you should leave the `source` and `rsh` configuration as is,
or only adjust it if your `docker-compose.yml` is modified accordingly.

### SSH key generation

For example, the SSH key can be generated using this command

```shell
ssh-keygen -t ed25519 -q -N "" -o -C "fsi-sync-key@$(hostname)" -f ./conf/lsyncd/sync.key
```

and transferred with this:

```shell
ssh-copy-id -i ./conf/lsyncd/sync.key user@fsi-secondary.domain.tld
```

After changing the configuration, you need to restart the lsyncd container and check that everything works as expected:

```shell
docker restart lsyncd
docker logs -f lsyncd
```

If you also want to synchronise the configuration of the FSI server or nginx, you will need to add another `sync`
section to `lsycd.conf.lua` which will contain the paths to their configurations.

### Anti-Pattern

You may be tempted to synchronise the `fsi-data` directory with `storage`.
Although this works in principle by disabling the scanner on the mirror instances,
it is still not a good idea.

The technical background lies in the internal, RAM-based caches of the FSI server.
In the case of accesses to assets that are being synchronised,
the server mirror server returns a 5xx error because it does not know about the internal status of the asset.

Synchronisation is also not a good idea in case of errors in `storage` processing.

**Even if it means a higher load per mirror server, you should not transfer the storage.**


## Backup

Of course, depending on how the images arrive on the image server, you should back up your images.
In any case, you should also backup the `conf/fsi-server` directory, as the server licence,
the created users and connectors are stored there.

In addition, the `$OVERLAY_PATH` and `$STORAGE_PATH/metadata` should be saved.
The search database does not need to be included, as it is automatically rebuilt after a restore.

### Does it make sense to back up the storage?

This depends very much on how fast your server is,
how many images you have and whether or how many mirror servers you have.

If you have a lot of images, it can take a very long time until a storage is ready for productive use again.
And it may be that the restore time without rebuild is considerably shorter,
if the storage is backed up.
This problem can be significantly reduced by using mirror servers.

## Using - Single Source and FSI Viewer

FSI Viewer offers zoom, 360° rotations, page turns in brochures, showcases, video-image combinations and 
[so on](https://www.neptunelabs.com/).
Product presentations become more vivid and compelling as you can view the product from all sides and explore every
from all sides and explore every detail of an image with fast, smooth zooming.

The viewer can be used on any device, including standard desktop
touchscreen displays, smartphones and tablets.

We have placed some examples in various [repositories](https://github.com/neptunelabs)
to illustrate the use of FSI Viewer.

## Nginx and SSL/TLS Certificates

The Nginx configuration in `conf/nginx` is prepared for LetsEncrypt certificates.
Of course, certificates without Let’s Encrypt can also be used.

For Let's Encrypt,
an additional directory should be created for the HTTP-01 Challenge.

```shell
mkdir ./conf/nginx/acme
```

If nginx is running, then a certificate can be generated via certbot:

```shell
certbot certonly --webroot \
-w ./conf/nginx/acme \
-d fsi.domain.tld \
--agree-tos \
-m my@email.tld
```

Then the Let's Encrypt directory must be included in the nginx container:

```
  nginx:
    volumes:
      - /etc/letsencrypt/live:/etc/letsencrypt/live
```

Finally, the file `conf/nginx/sites/fsi-server.conf` must be adapted:

```
ssl_certificate /etc/letsencrypt/live/fsi.domain.tld/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/fsi.domain.tld/privkey.pem;
ssl_trusted_certificate /etc/letsencrypt/live/fsi.domain.tld/chain.pem;
```

## Bottlenecks

FSI Server is a monolithic application, but it is highly parallelized internally.
Even with individual image requests,
both the CPU and the I/O system can be utilised to capacity through this parallelization.

Basically, the FSI servers tend to be **I/O bound** if they use a strong CPU.

In practice, therefore, the use of a powerful I/O system is necessary if you have high loads with
millions of hits per day and possibly millions of images.

Local SSD or NVMe are not essential, but helpful.
However, for very large numbers of images, customers often use spinning discs for cost reasons, which is usually sufficient.


## Benchmark
To help you assess whether your system is fast enough,
we have put together a useful benchmark based on *fio* and *sysbench*.
It respects the settings of `ASSET_PATH` and `STORAGE_PATH` in the `.env` file.

To start the test, the `benchmark.yml` is executed as a compose file, e.g. as follows.
The test takes about 4 minutes and requires at least **5GB** of hard disk space.

```shell
docker compose -f benchmark.yml run --rm benchmark
```
A result will look like this:

```
CPU-1            : 90.72 ops/sec
CPU-MAX          : 1383.10 ops/sec
MEMORY           : 7419.45 MiB/sec
I/O BW Assets    : 166 MB/sec
I/O IOPS Assets  : 39959 IOPS
I/O Storage      : 217 MB/sec
I/O IOPS Storage : 53023 IOPS
```

### How to interpret the values?

#### CPU-1 - ops/sec

This test tests classically via the calculation of prime numbers.
The test is performed on a single thread/core.
It tells you how fast a thread can work and corresponds to the clock frequency of the processor.

#### CPU-MAX - ops/sec

The same test, but using all available threads/cores.

#### MEMORY - MiB/sec

The RAM throughput with one thread is tested.

#### I/O - BW
Corresponds to the measured read bandwidth on this device.

#### I/O - IOPS

Corresponds to the measured I/O operations per second on this device.

#### Recommendations

In order to assess the values obtained
the following recommendations are based on our many years of experience with FSI Server.

*Minimum* should not be undercut, except perhaps for demo purposes.
For productive use of medium-sized websites and the use of single source imaging,
the *medium* values are at least required.

Individual values can also be undercut and are strongly dependent on the use of the FSI Server.

| Type        | CPU-1 ops/sec | CPU-MAX ops/sec | MEMORY MiB/sec | I/O BW | I/O IOPS |
|-------------|---------------|-----------------|----------------|--------|----------|
| Minimum     | 10            | 250             | 2000           | 30     | 10000    |
| Medium      | 15            | 700             | 3000           | 100    | 25000    |
| Recommended | 20            | 1000            | 4000           | 200    | 50000    |


## Licensing

You can use and try the software for as long as you like.
There are no feature restrictions or performance limitations in the
unregistered version, except that watermarks are displayed.
We also provide a free 60-day trial key without watermarks,
you can see how to get one
[here](https://www.neptunelabs.com/trial-options/trial/).

## What's next?

You can now benefit from the many features of FSI Server.
Learn how to use the server efficiently with your website by consulting our various [repositories] (https://github.com/neptunelabs).

Here are just a few:

When you use FSI Server with our dynamic Single Source Imaging (SSI) technology, you only need to provide one high-resolution source image for every image used on a website.
FSI Server dynamically generates images in different formats, sizes and qualities on the fly.

The [Image Repository](https://github.com/neptunelabs/fsi-image-samples) shows you how to create a website front page using SSI:

![SSI Image 1](https://docs.neptunelabs.com/fsi/server?type=image&source=images/samples/ssi-1.jpg&width=700)

and how to use the same images differently on a product listing page:

![SSI Image 2](https://docs.neptunelabs.com/fsi/server?type=image&source=images/samples/ssi-3.jpg&width=700)

or how to use the technology to create an even more sophisticated product configurator:

![SSI Image 3](https://docs.neptunelabs.com/fsi/server?type=image&source=images/samples/ssi-4.jpg&width=700)

You can also implement zoom on your website images, for example with the fly-out zoom shown in the [FSI QuickZoom repository](https://github.com/neptunelabs/fsi-quickzoom-samples):

![QuickZoom Image 1](https://docs.neptunelabs.com/fsi/server?type=image&source=images/samples/quick-1.jpg&width=700)

or the Zoom and Pan function in the [FSI Viewer repository](https://github.com/neptunelabs/fsi-viewer-samples):

![Zoom Image 1](https://docs.neptunelabs.com/fsi/server?type=image&source=images/samples/zoom-1.jpg&width=700)

But that's not all. Explore the other repositories to learn about various other features such as

Interactive Brochures in the [FSI Pages repository](https://github.com/neptunelabs/fsi-pages-samples):

or extensive configurator options in the [FSI Layers repository](https://github.com/neptunelabs/fsi-layers-samples):

![Layers Image 1](https://docs.neptunelabs.com/fsi/server?type=image&source=images/samples/layers-1.jpg&width=700)

You can also browse our [Documentation Area](https://docs.neptunelabs.com/) to learn more about the features and how to use them.
in detail, including tutorials for each viewer.

---

## Quick reference

* Where to file issues: https://github.com/neptunelabs/fsi-server-docker-v22/issues
* Supported architectures: **amd64**
* Documentation: https://docs.neptunelabs.com/
* More stuff on GitHub: https://github.com/neptunelabs
* FSI Server EULA: https://www.neptunelabs.com/terms-conditions/end-user-license-agreement/
