# .devcontainer/Dockerfile
ARG JULIA_VERSION
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# System deps
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends gcc g++ curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

USER vscode

# Redeclare after FROM to bring back into scope
ARG JULIA_VERSION

# Install juliaup + Julia into /home/vscode/.juliaup
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes --startup-selfupdate=0 \
    && /home/vscode/.juliaup/bin/juliaup add ${JULIA_VERSION} \
    && /home/vscode/.juliaup/bin/juliaup default ${JULIA_VERSION}

ENV PATH="/home/vscode/.juliaup/bin:${PATH}"

# Copy in the environment and workload script, owned by vscode
COPY --chown=vscode:vscode Project.toml Manifest.toml /home/vscode/
COPY --chown=vscode:vscode precompile_workload.jl /home/vscode/

RUN julia --project=/home/vscode -e 'import Pkg; Pkg.instantiate()' \
    && julia --project=/home/vscode /home/vscode/precompile_workload.jl