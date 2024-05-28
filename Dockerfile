FROM debian:bookworm-slim

# Very simple and slim MapServer Docker image.
# Inspired by:
# PDOK: https://github.com/PDOK/mapserver-docker
# and https://github.com/camptocamp/docker-mapserver/

LABEL maintainer="Just van den Broecke <just@justobjects.nl>"

ARG TZ="Europe/Amsterdam"

# Somehow does not work, default version in Bookworm is v8.0.0+
# ARG MAPSERVER_VERSION="7.2.*"

# May add extra Debian packages e.g. for mapScript support without needing to extend the Dockerfile
# ARG EXTRA_DEB_PACKAGES="python3-mapscript python3-pyproj python3-gdal python3-pil python3-psycopg2 libcairo2 python3-cairo"
ARG EXTRA_DEB_PACKAGES="ca-certificates curl"

ENV DEBIAN_FRONTEND="noninteractive" \
	DEB_PACKAGES="cgi-mapserver lighttpd lighttpd-mod-magnet ${EXTRA_DEB_PACKAGES}" \
	MS_DEBUGLEVEL="0" \
	MS_ERRORFILE="stderr" \
	MAX_REQUESTS_PER_PROCESS="1000" \
	LANG="C.UTF-8" \
	DEBUG="0" \
	MIN_PROCS="1" \
	MAX_PROCS="3" \
	MAX_LOAD_PER_PROC="4" \
	IDLE_TIMEOUT="20"

RUN apt update \
  && apt install -y --no-install-recommends ${DEB_PACKAGES} \
  && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
  && apt-get remove --purge ${DEB_BUILD_DEPS} -y \
  && apt-get -y --purge autoremove  \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY etc/lighttpd.conf /lighttpd.conf

EXPOSE 80

CMD ["lighttpd", "-D", "-f", "/lighttpd.conf"]
