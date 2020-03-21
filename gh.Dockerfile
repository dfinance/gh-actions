FROM docker:dind

RUN apk --update --no-cache add \
        openssh \
        curl \
        wget \
        bash \
        gettext \
        jq \
        gcc \
        openssl-dev \
        libffi-dev \
        python3-dev \
        musl-dev \
        python3 \
        rsync \
        py3-requests && \
    rm -rf /var/cache/apk/*

# Install kubectl
RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install helm
ENV HELM_VERSION=v3.1.2
RUN wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz; \
    tar -xf helm-${HELM_VERSION}-linux-amd64.tar.gz --strip-components=1 -C /usr/local/bin/ linux-amd64/helm; \
    rm helm-${HELM_VERSION}-linux-amd64.tar.gz

# Install python libs
RUN pip3 install --upgrade wheel PyGithub python-gitlab python-telegram-bot

WORKDIR /opt/app
COPY ./scripts/ /usr/local/bin/
