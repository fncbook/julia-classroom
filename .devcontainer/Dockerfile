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

# The baked-in Julia project lives in the user's home directory.
# Setting JULIA_PROJECT here makes it the default for all Julia processes
# in the container — terminal, language server, and Jupyter kernels —
# without requiring students to pass --project on every invocation.
ENV JULIA_PROJECT=/home/vscode

# Copy in the environment and workload script, owned by vscode
COPY --chown=vscode:vscode Project.toml Manifest.toml /home/vscode/
COPY --chown=vscode:vscode precompile_workload.jl /home/vscode/

# Instantiate (resolves and precompiles all packages into ~/.julia/compiled/),
# then run the workload to warm up as many code paths as possible.
RUN julia -e 'import Pkg; Pkg.instantiate()' \
    && julia /home/vscode/precompile_workload.jl

# Register the Jupyter kernel so notebooks always use this project.
# IJulia.installkernel records --project=/home/vscode in the kernel spec,
# which overrides JULIA_PROJECT for kernel processes that don't inherit it.
RUN julia -e 'using IJulia; IJulia.installkernel("Julia", "--project=/home/vscode")'
