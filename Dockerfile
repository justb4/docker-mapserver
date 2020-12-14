FROM debian:buster-slim

# FROM debian:bullseye-slim  BullsEye is moving target in versions and tiny unexpected issues

# Very simple and slim MapServer Docker image.
# Inspired by: https://hub.docker.com/r/camptocamp/mapserver/dockerfile
# and: https://github.com/PDOK/mapserver-docker

LABEL maintainer="Just van den Broecke <just@justobjects.nl>"

ARG TZ="Europe/Amsterdam"

# BullsEye MS 7.6.2-1 includes Proj 7.2.0-1 and GDAL 3.2.0  - maybe later
# ARG MAPSERVER_VERSION="7.6.*"

# Buster MS 7.2.2-1 includes Proj 5.2.0-1 and GDAL 2.4.0
ARG MAPSERVER_VERSION="7.2.*"

# May add extra Debian packages e.g. for mapScript support without needing to extend the Dockerfile
# ARG EXTRA_DEB_PACKAGES="python3-mapscript python3-pyproj python3-gdal python3-pil python3-psycopg2 libcairo2 python3-cairo"
ARG EXTRA_DEB_PACKAGES="ca-certificates curl"
ARG LIGHTTPD_VERSION=1.4.*
# ARG LIGHTTPD_VERSION=1.4.56-1   Bullseye

ENV DEBIAN_FRONTEND="noninteractive" \
	MS_DEBUGLEVEL="0" \
	MS_ERRORFILE="stderr" \
	MAX_REQUESTS_PER_PROCESS="1000" \
	LANG="C.UTF-8" \
	DEBUG="0" \
	MIN_PROCS="1" \
	MAX_PROCS="3" \
	MAX_LOAD_PER_PROC="4" \
	IDLE_TIMEOUT="20" \
	CURL_CA_BUNDLE="/mycacert.pem"

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
      cgi-mapserver=${MAPSERVER_VERSION} \
      lighttpd=${LIGHTTPD_VERSION} \
      lighttpd-mod-magnet=${LIGHTTPD_VERSION} \
      ${EXTRA_DEB_PACKAGES} \
    && apt-get clean

COPY etc/lighttpd.conf /lighttpd.conf
COPY etc/cacert.pem /mycacert.pem

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/lighttpd.conf"]
