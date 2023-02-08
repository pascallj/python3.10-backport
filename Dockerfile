FROM debian:bullseye-slim AS build-system
RUN echo '\
deb http://deb.debian.org/debian bookworm main\n\
deb-src http://deb.debian.org/debian bookworm main' \
>> /etc/apt/sources.list
RUN echo '\
Package: *\n\
Pin: release n=bookworm\n\
Pin-Priority: 1' \
> /etc/apt/preferences.d/99pinning
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends devscripts equivs
WORKDIR /usr/local/src
RUN apt-get source python3.10
RUN mv python3.10*/ python-source
WORKDIR python-source
ADD python3.10.diff .
RUN patch -p1 < python3.10.diff
ADD changelog_previous .
RUN if [ -s changelog_previous ]; then echo "$(cat changelog_previous)\n\
\n\
$(cat debian/changelog)" > debian/changelog; fi
ARG NAME
ARG EMAIL
ARG CHANGE
RUN dch --bpo "$CHANGE"

FROM build-system AS native
RUN mk-build-deps --install --tool 'apt-get -y --no-install-recommends'
RUN debuild -b -uc -us
RUN mkdir debs && mv ../*.deb debs
CMD mkdir -p artifacts && cp -r debs/. artifacts && cp ../python3.10*.build ../python3.10*.buildinfo artifacts

FROM build-system AS crossbuild
ARG CROSSBUILD
RUN [ ! -z "$CROSSBUILD" ]
RUN dpkg --add-architecture $CROSSBUILD
RUN apt-get update
COPY --from=native /usr/local/src/python-source/debs native-debs
RUN cd native-debs && apt-get install -y ./libpython3.10-minimal*.deb \
	./libpython3.10-stdlib*.deb \
	./libpython3.10_*.deb \
	./python3.10-minimal*.deb \
	./python3.10_*.deb
ADD crossbuild-dep.diff .
RUN patch -p1 < crossbuild-dep.diff
# For some reason mk-build-deps cannot install directly when cross-compiling
RUN mk-build-deps --arch $CROSSBUILD --host-arch $CROSSBUILD
RUN apt-get install -y --no-install-recommends ./python3.10-cross-build-deps*.deb
RUN DEB_BUILD_OPTIONS='nocheck nobench' debuild -b -uc -us -a$CROSSBUILD
RUN mkdir debs && mv ../*.deb debs
CMD mkdir -p artifacts && cp -r debs/. artifacts && cp ../python3.10*.build ../python3.10*.buildinfo artifacts
