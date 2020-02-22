README
======

Advantages of RancherOS
-----------------------

* Small footprint (ISO image approximately 150 MB).
* It can be run as a 'live disk' if ephemeral images are needed.
* It can be installed to disk quickly.
* Installation is fast and non-interactive.
* Installation can be configured in a simple YAML file.
* Many OS' and Docker configuration parameters can be read and written 
using a simple CLI.
* It always runs the latest version of Docker.
* Ideal for developers and sysadmin alike.

Hardware requirements
---------------------

Currently (v. >= 1.5), RancherOS requires 1 GB of RAM to boot from the ISO
image and to be installed on disk.

Installation using docker-machine
---------------------------------

RancherOS can be installed using [`docker-machine`](https://docs.docker.com/machine/)
and the VirtualBox driver using the following command:

```shell script 
$ docker-machine \
    create -d virtualbox \
    --virtualbox-boot2docker-url https://releases.rancher.com/os/latest/rancheros.iso \
    --virtualbox-memory 2048 \
    my-machine
```    

`docker-machine` is a CLI that has helpful features that can help developers
quickly create virtual machines, create machines remotely, access them, and
configure the local `docker` client.

To configure the `docker` client to connect to a Docker daemon running inside
a VM created with `docker-machine` and named `my-machine`, the following
command can be used:

```shell script 
$ eval $(docker-machine env my-machine)
```

The latest release can be downloaded from its official GitHub 
[repository](https://github.com/docker/machine/releases/).

Installation on bare-metal or using a hypervisor
------------------------------------------------

A bootable ISO image can be used to install RancherOS on a bare metal server
or as a virtual machine on a hypervisor.

Preconfigure ISO images for a huge variety of hypervisors can be found on
the official GitHub [repository](https://github.com/rancher/os/releases/).

Once the image has been booted, it can be installed on disk using the following
command:

```shell script 
$ sudo ros install -c cloud-config.yml -d /dev/sda
```                                             

`cloud-config.yml` is a configuration file that is used to configure the OS.
A minimal `cloud-config.yml` should contain at least the public key to
authorise a remote SSH login, since RancherOS does not autologin once installed
to disk.

A minimal configuration file is the following:

```yaml
ssh_authorized_keys:
  - ssh-rsa AAAAB3N.....
```

Configure the Docker daemon to listen on a TCP port
---------------------------------------------------

Users may typically want to configure the Docker daemon to listen on a TCP
port, in order to allow remote connections.  This can be accomplished setting
the `rancher.docker.extra_args` configuration property, by passing the
`-H 0.0.0.0:2375` option:

```shell script
$ sudo ros config set rancher.docker.extra_args [-H,0.0.0.0:2375]
```

Alternatively, the same property can be specified in the `cloud-config.yml`
file:

```yaml 
rancher:
  docker:
    extra_args:
      - -H
      - 0.0.0.0:2375
```

To configure the Docker daemon to use TLS, the `rancher.docker.tls_args`
should be used instead as in the following example:

```shell script
tls_args:
- --tlsverify
- --tlscacert=/etc/docker/tls/ca.pem
- --tlscert=/etc/docker/tls/server-cert.pem
- --tlskey=/etc/docker/tls/server-key.pem
- -H=0.0.0.0:2376
```                             

Configuring insecure registries
-------------------------------

To configure the Docker daemon to allow communication to an insecure
registry, the `rancher.docker.insecure_registries` property should be
used as in the following example:

```yaml
insecure_registry:
- registry:5000
```