FROM debian:bullseye-slim
# Very simple and slim MapServer Docker image.
# Inspired by: https://hub.docker.com/r/camptocamp/mapserver/dockerfile
# and: https://github.com/PDOK/mapserver-docker

LABEL maintainer="Just van den Broecke <just@justobjects.nl>"

ARG TZ="Europe/Amsterdam"
ARG MAPSERVER_VERSION="7.6.*"
# May add extra Debian packages e.g. for mapScript support without needing to extend the Dockerfile
# ARG EXTRA_DEB_PACKAGES="python3-mapscript python3-pyproj python3-gdal python3-pil python3-psycopg2 libcairo2 python3-cairo"
ARG EXTRA_DEB_PACKAGES=""
ARG LIGHTTPD_VERSION=1.4.55-1

ENV DEBIAN_FRONTEND="noninteractive" \
	MS_DEBUGLEVEL="0" \
	MS_ERRORFILE="stderr" \
	MAX_REQUESTS_PER_PROCESS="1000" \
	LANG="C.UTF-8" \
	DEBUG="0" \
	MIN_PROCS="1" \
	MAX_PROCS="3" \
	MAX_LOAD_PER_PROC="4" \
	IDLE_TIMEOUT="20"

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
      cgi-mapserver=${MAPSERVER_VERSION} \
      lighttpd=${LIGHTTPD_VERSION} \
      lighttpd-mod-magnet=${LIGHTTPD_VERSION} \
      ${EXTRA_DEB_PACKAGES} \
    && apt-get clean

COPY etc/lighttpd.conf /lighttpd.conf

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/lighttpd.conf"]
