## How to use


root@603c91fa896f:/mnt/hls# ls
kitecam-0.ts  kitecam-1.ts  kitecam-2.ts  kitecam-3.ts  kitecam-4.ts  kitecam-5.ts  kitecam.m3u8


[ec2-user@ip-192-168-1-51 nginx-rtmp]$ docker run -d --restart=always 215371600831.dkr.ecr.af-south-1.amazonaws.com/nginx-rtmp:latest
f1b6666ef472147d78e0190bf069bf48ee77f313047ad2579445e5e5ddabcd01
[ec2-user@ip-192-168-1-51 nginx-rtmp]$ docker ps
CONTAINER ID   IMAGE                                                             COMMAND                  CREATED         STATUS                           PORTS                NAMES
f1b6666ef472   215371600831.dkr.ecr.af-south-1.amazonaws.com/nginx-rtmp:latest   "nginx -g 'daemon of…"   7 seconds ago   Up 1 second (health: starting)   1935/tcp, 8000/tcp   heuristic_austin




* For the simplest case, just run a container with this image:

```bash
docker run -d -p 1935:1935 --name nginx-rtmp nginx-rtmp
```

## How to test with OBS Studio and VLC

* Run a container with the command above

* Open [OBS Studio](https://obsproject.com/)
* Click the "Settings" button
* Go to the "Stream" section
* In "Stream Type" select "Custom Streaming Server"
* In the "URL" enter the `rtmp://<ip_of_host>/live` replacing `<ip_of_host>` with the IP of the host in which the container is running. For example: `rtmp://192.168.0.30/live`
* In the "Stream key" use a "key" that will be used later in the client URL to display that specific stream. For example: `test`
* Click the "OK" button
* In the section "Sources" click the "Add" button (`+`) and select a source (for example "Screen Capture") and configure it as you need
* Click the "Start Streaming" button


* Open a [VLC](http://www.videolan.org/vlc/index.html) player (it also works in Raspberry Pi using `omxplayer`)
* Click in the "Media" menu
* Click in "Open Network Stream"
* Enter the URL from above as `rtmp://<ip_of_host>/live/<key>` replacing `<ip_of_host>` with the IP of the host in which the container is running and `<key>` with the key you created in OBS Studio. For example: `rtmp://192.168.0.30/live/test`
* Click "Play"
* Now VLC should start playing whatever you are transmitting from OBS Studio

## Debugging

If something is not working you can check the logs of the container with:

```bash
docker logs nginx-rtmp
```

## Technical details

* This image is built from the same base official images that most of the other official images, as Python, Node, Postgres, Nginx itself, etc. Specifically, [buildpack-deps](https://hub.docker.com/_/buildpack-deps/) which is in turn based on [debian](https://hub.docker.com/_/debian/). So, if you have any other image locally you probably have the base image layers already downloaded.

* It is built from the official sources of **Nginx** and **nginx-rtmp-module** without adding anything else. (Surprisingly, most of the available images that include **nginx-rtmp-module** are made from different sources, old versions or add several other components).

* It has a simple default configuration that should allow you to send one or more streams to it and have several clients receiving multiple copies of those streams simultaneously. (It includes `rtmp_auto_push` and an automatic number of worker processes).
