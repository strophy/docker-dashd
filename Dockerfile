FROM phusion/baseimage:bionic-1.0.0
LABEL maintainer="holger@dash.org,leon.white@dash.org"

ARG USER_ID
ARG GROUP_ID
ARG VERSION

ENV HOME /dash

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}
RUN groupadd -g ${GROUP_ID} dash
RUN useradd -u ${USER_ID} -g dash -s /bin/bash -m -d /dash dash
RUN mkdir /dash/.dashcore
RUN chown dash:dash -R /dash

RUN apt-get update
RUN /sbin/install_clean -y wget

RUN mach=$(uname -m)
RUN case $mach in armv7l) arch="arm-linux-gnueabihf"; ;; aarch64) arch="aarch64-linux-gnu"; ;; x86_64) arch="x86_64-linux-gnu"; ;;  *) echo "ERROR: Machine type $mach not supported."; ;; esac
RUN wget https://github.com/dashpay/dash/releases/download/${VERSION}/dashcore-${VERSION}-$arch.tar.gz -P /tmp
RUN tar -xvf /tmp/dashcore-*.tar.gz -C /tmp/
RUN cp /tmp/dashcore*/bin/*  /usr/local/bin
RUN rm -rf /tmp/dashcore*

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

USER dash

VOLUME ["/dash"]

EXPOSE 9998 9999 19998 19999

WORKDIR /dash

CMD ["dash_oneshot"]
