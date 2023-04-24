## Nginx-RTMP

Serving a [live-camera feed](https://kitesurfcapetown.co.za/live-webcam/) with less than 5s latency delay and high reliability.

It's possible to run this container directly on ECS (Fargate) or EKS, but for the purpose of cost-optimization, I'm choosing to run on a bare EC2 instance.

* To build a container, run this container but substitute your RTMP details in the build arguments:

```bash
docker build -t nginx-rtmp --build-arg RTMP_USER=$USER --build-arg RTMP_PASSWORD=$PASSWORD --build-arg STREAM_URL=$URL .
```

* For the simplest case, just run a container with this image:

```bash
docker run -d --restart=always nginx-rtmp:latest # Example 215371600831.dkr.ecr.af-south-1.amazonaws.com/nginx-rtmp:latest
```

```bash
[ec2-user@ip-192-168-1-51 nginx-rtmp]$ docker run -d --restart=always 215371600831.dkr.ecr.af-south-1.amazonaws.com/nginx-rtmp:latest

[ec2-user@ip-192-168-1-51 nginx-rtmp]$ docker ps
CONTAINER ID   IMAGE                                                             COMMAND                  CREATED         STATUS                           PORTS                NAMES
f1b6666ef472   215371600831.dkr.ecr.af-south-1.amazonaws.com/nginx-rtmp:latest   "nginx -g 'daemon of…"   7 seconds ago   Up 1 second (health: starting)   1935/tcp, 8000/tcp   heuristic_austin
```

## Debugging

If something is not working you can check the logs of the container with:

```bash
docker logs nginx-rtmp
```

The container has [healthchecks](https://docs.docker.com/engine/reference/builder/#healthcheck) defined. If you find your container dying prematurely it's probably because the healthcheck expects Nginx to immediately start generating HLS fragments but if it can't, it assumes the container is unhealthy.

A healthy container should look similar to this:

```bash
root@603c91fa896f:/mnt/hls# ls
kitecam-0.ts  kitecam-1.ts  kitecam-2.ts  kitecam-3.ts  kitecam-4.ts  kitecam-5.ts  kitecam.m3u8
```

## Technical details

* This image is built from the same base official images that most of the other official images, as Python, Node, Postgres, Nginx itself, etc. Specifically, [buildpack-deps](https://hub.docker.com/_/buildpack-deps/) which is in turn based on [debian](https://hub.docker.com/_/debian/).

* It is built from the official sources of **Nginx** and **nginx-rtmp-module** without adding anything else.

* It has a simple default configuration that should allow you to get started with generating your own stream.
