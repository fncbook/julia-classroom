# .devcontainer/Dockerfile
ARG JULIA_VERSION
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# System deps
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends gcc g++ curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Redeclare after FROM to bring back into scope
ARG JULIA_VERSION

# Install juliaup + Julia
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes --startup-selfupdate=0 \
    && /root/.juliaup/bin/juliaup add ${JULIA_VERSION} \
    && /root/.juliaup/bin/juliaup default ${JULIA_VERSION}

ENV PATH="/root/.juliaup/bin:${PATH}"

# Copy in the environment and workload script
COPY Project.toml Manifest.toml /opt/julia-env/
COPY precompile_workload.jl /opt/julia-env/

# Instantiate (download + precompile all packages into .ji cache),
# then run the workload script to warm up as many code paths as possible.
RUN julia --project=/opt/julia-env -e 'import Pkg; Pkg.instantiate()' \
    && julia --project=/opt/julia-env /opt/julia-env/precompile_workload.jl
