ARG VARIANT=latest
FROM docker.io/library/ubuntu:$VARIANT

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

COPY library-scripts/* /tmp/scripts/

RUN \
    bash /tmp/scripts/common-debian.sh "true"; \
    bash /tmp/scripts/setup-user-debian.sh "${USERNAME}" "${USER_UID}" "${USER_GID}"; \
    bash /tmp/scripts/hadolint-debian.sh "2.10.0"; \
    bash /tmp/scripts/shfmt-debian.sh "3.5.1"; \
    bash /tmp/scripts/shellcheck-debian.sh "0.8.0"; \
    bash /tmp/scripts/editorconfig-debian.sh "2.6.0"; \
    bash /tmp/scripts/trivy-debian.sh; \
    bash /tmp/scripts/quarto-debian.sh "1.3.26"; \
    apt-get autoremove; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/scripts
