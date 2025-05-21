FROM ghcr.io/zilvertonz/shared-github-actions:v1-base AS base

RUN dnf update -y && \
    dnf install -y \
        maven-local-amazon-corretto8 \
        apache-commons-lang3 \
        java-1.8.0-amazon-corretto \
        sudo \
        wget

ARG GLUE_VERSION=4.0
ARG SPARK_DISTR=spark-3.3.0-amzn-1-bin-3.3.3-amzn-0
ARG SQLITE_JDBC_JAR_VER=3.46.0.0
ARG SQLITE_JDBC_JAR_DIR=/github/workspace/aws-glue-libs/jarsv1
ARG CONFTEST_VER=0.53.0

RUN uv python install 3.10 && \
    uv python pin 3.10

ENV HOME="/github/workspace"
# Getting spark distribution
RUN curl https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-$GLUE_VERSION/$SPARK_DISTR.tgz -o $SPARK_DISTR.tgz
RUN tar zxvf $SPARK_DISTR.tgz
RUN rm $SPARK_DISTR.tgz

ENV SPARK_HOME="/github/workspace/spark"
ENV JAVA_HOME="/usr/lib/jvm/java-1.8.0-amazon-corretto.x86_64/"
ENV PATH="$PATH:/usr/lib/jvm/java-1.8.0-amazon-corretto.x86_64/bin/:/github/workspace/spark/bin:/github/workspace/aws-glue-libs/bin/"

# Configure aws-glue-libs using spark distro and mvn from above
RUN git clone https://github.com/awslabs/aws-glue-libs.git aws-glue-libs

# glue-setup.sh runs mvn
# RUN mv .m2 .m2.tmp
RUN bash /github/workspace/aws-glue-libs/bin/glue-setup.sh
RUN mvn dependency:copy -Dartifact=org.xerial:sqlite-jdbc:${SQLITE_JDBC_JAR_VER} -DoutputDirectory=${SQLITE_JDBC_JAR_DIR}

RUN echo "timeout=600" >> /etc/dnf/dnf.conf

RUN mkdir -p /github/workspace/.bin
ENV PYTHONPATH=/github/workspace/aws-glue-libs/PyGlue.zip:/github/workspace/spark/python/lib/py4j-0.10.9.5-src.zip:/github/workspace/spark/python/
ENV SPARK_CONF_DIR=/github/workspace/aws-glue-libs/conf
RUN wget https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VER}/conftest_${CONFTEST_VER}_Linux_x86_64.tar.gz \
    && tar xzf conftest_${CONFTEST_VER}_Linux_x86_64.tar.gz \
    && cp conftest /github/workspace/.bin/ \
    && rm conftest_${CONFTEST_VER}_Linux_x86_64.tar.gz

RUN mv /etc/profile.d/which2.sh /etc/profile.d/which2.sh.disabled

RUN uv build --wheel -o /usr/local/bin/aws-glue-libs/ /github/workspace/aws-glue-libs/
RUN java -version

WORKDIR /github/workspace/
