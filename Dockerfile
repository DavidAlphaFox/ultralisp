FROM 40ants/base-lisp-image:0.12.0-sbcl-bin as base

EXPOSE 80
EXPOSE 4005

# These a dev dependencies to simplify log reading and support
# file search from remote Emacs.
RUN apt-get update && \
    apt-get install -y \
            python-pip \
            silversearcher-ag \
            lsof \
            postgresql-client && \
    pip install jsail dumb-init

RUN mkdir -p /tmp/s6 && cd /tmp/s6 && \
    git clone https://github.com/skarnet/skalibs && cd skalibs && \
    git checkout d6169d90477a1b467545408f4ea9570ed4f36bf9 && \
    ./configure && make install && cd /tmp/s6 && \
    git clone https://github.com/skarnet/execline && cd execline && \
    git checkout 3856ce50bfc3fc23d8b819f2a3970cf2af66882b && \
    ./configure && make install && cd /tmp/s6 && \
    git clone https://github.com/skarnet/s6 && cd s6 \
    git checkout 19ecbe91d2ef699f3d2a063c50cbff4d7e46eb1e && \
    ./configure --with-lib=/usr/lib/execline && make install && \
    cd / && rm -fr /tmp/s6

ENV CC=gcc
COPY qlfile qlfile.lock app-deps.asd /app/
RUN install-dependencies

COPY . /app
COPY ./docker/.distignore /root/.config/quickdist/

RUN qlot exec ros build \
    /app/roswell/worker.ros && \
    mv /app/roswell/worker /app/worker
RUN qlot exec ros build \
    /app/roswell/ultralisp-server.ros && \
    mv /app/roswell/ultralisp-server /app/ultralisp-server
RUN qlot exec ros run \
    --eval '(asdf:make :packages-extractor)' && \
    mv /app/src/packages-extractor /app/packages-extractor

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["/app/docker/entrypoint.sh"]


# Next stage is for development only
FROM base as worker
COPY ./docker/s6 /etc/s6
ENTRYPOINT ["s6-svscan", "/etc/s6"]


# Next stage is for development only
FROM base as dev
RUN ros install 40ants/gen-deps-system
ENTRYPOINT ["/app/docker/dev-entrypoint.sh"]

# To run Mito commands
FROM dev as mito
RUN ros install svetlyak40wt/mito/add-host-argument

# https://medium.com/the-code-review/how-to-use-entrypoint-with-docker-and-docker-compose-1c2062aa17a2
ENTRYPOINT ["/app/docker/mito.sh"]


FROM postgres:10 as db-ops
COPY ./docker/dev-entrypoint.sh /entrypoint.sh
WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
