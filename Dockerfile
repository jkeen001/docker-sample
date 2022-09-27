FROM registry.access.redhat.com/ubi8/ubi

EXPOSE 8080

WORKDIR /tmp
RUN mkdir -p /usr/lib/jvm

RUN curl -O https://download.java.net/java/GA/jdk18.0.2/f6ad4b4450fd4d298113270ec84f30ee/9/GPL/openjdk-18.0.2_linux-x64_bin.tar.gz

RUN tar zxvf openjdk-18.0.2_linux-x64_bin.tar.gz -C /usr/lib/jvm

RUN echo 'export JAVA_HOME=/usr/lib/jvm/jdk-18.0.2/bin/java' > /etc/profile.d/openjdk18.sh && \
    echo 'export PATH=$PATH:/usr/lib/jvm/jdk-18.0.2/bin' >> /etc/profile.d/openjdk18.sh

RUN rm -rf openjdk-18.0.2_linux-x64_bin.tar.gz

ARG user=debugger
# ARG group=debugger
ARG uid=1000
ARG gid=0
# RUN groupadd -r ${group} -g ${gid}
RUN useradd -u ${uid} -r -g ${gid} -m -s /sbin/nologin -c "Docker image user" ${user}

ENV HOME=/home/${user}
ENV JAVA_HOME=/usr/lib/jvm/jdk-18.0.2/bin/java
ENV PATH=${PATH}:/usr/lib/jvm/jdk-18.0.2/bin

USER ${uid}
WORKDIR /home/${user}
RUN chmod -R 775 /home/${user}
RUN echo "This container is for running confluent cli commands from a terminal inside the container." > index.html
RUN mkdir confluent
RUN curl -sL --http1.1 https://cnfl.io/cli | sh -s -- -b ./confluent v2.24.2

CMD ["jwebserver", "-b", "0.0.0.0", "-p", "8080"]
