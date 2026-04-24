# .devcontainer/Dockerfile
ARG JULIA_VERSION
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG JULIA_VERSION

# System deps
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends gcc g++ curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Julia depot and project live in /opt (outside /home/vscode) so the multi-GB
# package cache is not chowned on every container start when Dev Containers
# remap the user UID. Only juliaup itself (small) stays under home.
ENV JULIA_DEPOT_PATH=/opt/julia-depot
ENV JULIA_PROJECT=/opt/julia-env
RUN mkdir -p /opt/julia-depot /opt/julia-env \
    && chown -R vscode:vscode /opt/julia-depot /opt/julia-env

# Switch to vscode for all remaining steps. The base image ends as root;
# buildx can silently cache layers from a root context, so this must come
# right before the first user-specific command.
USER vscode
WORKDIR /home/vscode

# Install juliaup into /home/vscode/.juliaup (its default location).
# The Julia VS Code extension specifically looks for juliaup here; if it is
# missing the extension opens a dialog prompting the user to install Julia.
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes --startup-selfupdate=0 \
    && /home/vscode/.juliaup/bin/juliaup add ${JULIA_VERSION} \
    && /home/vscode/.juliaup/bin/juliaup default ${JULIA_VERSION}

ENV PATH="/home/vscode/.juliaup/bin:${PATH}"

ENV JULIA_CPU_TARGET="generic;cortex-a57;thunderx2t99;carmel;apple-m1,clone_all"

# Copy the environment files and workload into the baked-in project.
COPY --chown=vscode:vscode Project.toml Manifest.toml /opt/julia-env/
COPY --chown=vscode:vscode precompile_workload.jl /opt/julia-env/

# Instantiate, register the Jupyter kernel, then run the workload.
# Registering the kernel BEFORE the workload means IJulia gets loaded and
# fully precompiled as part of the single workload pass that follows.
RUN julia -e 'import Pkg; Pkg.instantiate(); Pkg.precompile()' \
    && julia -e 'using IJulia; IJulia.installkernel("Julia", "--project=/opt/julia-env"; env=Dict("JULIA_PROJECT"=>"/opt/julia-env", "JULIA_DEPOT_PATH"=>"/opt/julia-depot"))' \
    && julia /opt/julia-env/precompile_workload.jl
