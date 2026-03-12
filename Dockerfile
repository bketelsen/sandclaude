FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    jq \
    unzip \
    openssh-client \
    make \
    build-essential \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabi \
    gcc-mingw-w64-x86-64 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -fsSL https://go.dev/dl/go1.26.1.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install GoReleaser (to /usr/local/bin so it's available to all users)
ENV GOBIN=/usr/local/bin
RUN go install github.com/goreleaser/goreleaser/v2@latest
ENV GOBIN=

# Install Python 3
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install gh (GitHub CLI)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Run as non-root user matching host UID/GID (overridable at runtime)
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -f -g ${GROUP_ID} claude && \
    useradd -m -u ${USER_ID} -g claude -o claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/claude

USER claude
ENV HOME=/home/claude
ENV GOPATH=/home/claude/go
ENV PATH="/home/claude/go/bin:${PATH}"

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/claude/.claude/bin:/home/claude/.local/bin:${PATH}"
ENV TERM=xterm-256color

COPY --chown=claude:claude entrypoint.sh /home/claude/entrypoint.sh

ENTRYPOINT ["/home/claude/entrypoint.sh"]
