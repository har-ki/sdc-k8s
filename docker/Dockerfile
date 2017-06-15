FROM harki/centos-java8:latest

MAINTAINER Harikiran <hari@streamsets.com>

ENV SDC_USER=sdc
ENV SDC_DIST="/opt/streamsets-datacollector" \
    SDC_DATA=/data \
    SDC_LOG=/logs \
    SDC_CONF=/etc/sdc \
    SDC_RESOURCES=/resources
ENV STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/libs-common-lib"

RUN yum update -y && yum upgrade -y && yum install -y wget perl

RUN groupadd ${SDC_USER} && \
  useradd ${SDC_USER} -g ${SDC_USER}

# ARG is new in Docker 1.9 and not yet supported by Docker Hub Automated Builds
# ARG SDC_VERSION

ENV SDC_VERSION 2.6.0.0

RUN cd /tmp && \
  curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-core-${SDC_VERSION}.tgz" && \
  curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-apache-kafka_0_10-lib-${SDC_VERSION}.tgz" && \
  curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-aws-lib-${SDC_VERSION}.tgz" && \
  curl -O -L "https://archives.streamsets.com/datacollector/${SDC_VERSION}/tarball/streamsets-datacollector-stats-lib-${SDC_VERSION}.tgz" && \
  tar xvf "streamsets-datacollector-core-${SDC_VERSION}.tgz" -C /opt/ && \
  tar xzf "streamsets-datacollector-apache-kafka_0_10-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  tar xzf "streamsets-datacollector-aws-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  tar xzf "streamsets-datacollector-stats-lib-${SDC_VERSION}.tgz" -C /opt/ && \
  rm  "/tmp/streamsets-datacollector-core-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-apache-kafka_0_10-lib-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-aws-lib-${SDC_VERSION}.tgz" "/tmp/streamsets-datacollector-stats-lib-${SDC_VERSION}.tgz"  && \
  mv "/opt/streamsets-datacollector-${SDC_VERSION}" "${SDC_DIST}"

# Log to stdout for docker instead of sdc.log for compatibility with docker.
RUN sed -i 's|DEBUG|INFO|' "${SDC_DIST}/etc/sdc-log4j.properties" && \
sed -i 's|INFO, streamsets|INFO, stdout|' "${SDC_DIST}/etc/sdc-log4j.properties"

# Create data directory and optional mount point
RUN mkdir -p "${SDC_DATA}" /mnt "${SDC_LOG}" "${SDC_RESOURCES}"

# Move configuration to /etc/sdc
RUN mv "${SDC_DIST}/etc" "${SDC_CONF}"

# Disable authentication by default, overriable with custom sdc.properties.
RUN sed -i 's|\(http.authentication=\).*|\1none|' "${SDC_CONF}/sdc.properties"

# Setup filesystem permissions
RUN chown -R "${SDC_USER}:${SDC_USER}" "${SDC_CONF}" "${SDC_DATA}" "${SDC_LOG}" "${SDC_RESOURCES}"

# /mnt is a generic mount point for mounting volumes from other containers or the host
#   such as an input directory for directory spooling.
# SDC_DATA is a volume for storing collector state. Do not share this between containers.
# SDC_CONF is a olume containing configuration of the data collector. This can be shared.
# SDC_LOG is an optional volume for file based logs. You must provide a custom sdc-log4j.properties file to use this.
# SDC_RESOURCES is where resource files such as runtime:conf resources and Hadoop configuration can be placed.
# STREAMSETS_LIBRARIES_EXTRA_DIR is where extra libraries such as JDBC drivers should go.
VOLUME /mnt ${SDC_DATA} ${SDC_CONF} ${SDC_LOG} ${SDC_RESOURCES} ${STREAMSETS_LIBRARIES_EXTRA_DIR}

#USER ${SDC_USER}

EXPOSE 18630
COPY docker-entrypoint.sh /
COPY pre-stop.sh /

RUN chmod +x /docker-entrypoint.sh
RUN chmod +x /pre-stop.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc"]
