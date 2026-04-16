# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# System deps
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends gcc g++ curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install juliaup + Julia 1.11.9
RUN curl -fsSL https://install.julialang.org | sh -s -- --yes --startup-selfupdate=0 \
    && /root/.juliaup/bin/juliaup add 1.11.9 \
    && /root/.juliaup/bin/juliaup default 1.11.9

ENV PATH="/root/.juliaup/bin:${PATH}"

# Copy in the environment and workload script
COPY Project.toml Manifest.toml /opt/julia-env/
COPY precompile_workload.jl /opt/julia-env/

# Instantiate (download + precompile all packages into .ji cache),
# then run the workload script to warm up as many code paths as possible.
RUN julia --project=/opt/julia-env -e 'import Pkg; Pkg.instantiate()' \
    && julia --project=/opt/julia-env /opt/julia-env/precompile_workload.jl
