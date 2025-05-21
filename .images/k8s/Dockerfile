FROM amazonlinux:2023 as base

COPY --chmod=0755 scripts /opt/scripts/

ENV HOME=/github/home UV_NATIVE_TLS=true UV_REQUEST_TIMEOUT=60 UV_INSTALL_DIR="/usr/local/bin"

ARG KUBECTL_VERSION="1.26.0" 

RUN mkdir -p /github/workspace && \
    sh /opt/scripts/certs.sh && \
    dnf update -y && \
    dnf install -y \
    awscli \
    findutils \
    git \
    gzip \
    zip \
    jq \
    python3-pip \
    python3-wheel \
    tar \
    which && \
    curl -sSfLO \
    https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    sh /opt/scripts/install-bashrc.sh && \
    sh /opt/scripts/install-git.sh && \
    curl -L https://raw.githubusercontent.com/warrensbox/tgswitch/release/install.sh | bash && \
    curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/master/install.sh | bash && \
    dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && \
    dnf install -y gh --repo gh-cli && \
    uv python install 3.12 && \
    sh /opt/scripts/clean.sh

WORKDIR /github/workspace/
