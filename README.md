# Julia Classroom Template

This is a GitHub template repository to set up a Julia environments for use in [Fundamentals of Numerical Computation](https://fncbook.com).

It provides a pre-built Docker image with Julia and all necessary packages installed and precompiled, so you can get a working environment in about 5 minutes. It can be used for [GitHub Classroom](https://classroom.github.com/) assignments and opened in a Codespace.

## Using this template

Regardless of which option below is chosen, students completing assignments in GitHub Classroom will have to push changed and new files in order to make them visible to the instructor.

### Option 1: GitHub Codespace: minimal fuss, plenty of waiting around

In this option, everything happens in the cloud. Students open a fully configured Julia environment in their browser or within VS Code. A Codespace will automatically give seamless access to new and changed files between invocations. 

1. Click **Use this template → Create a new repository** to generate your assignment repo.
2. Edit the repo contents for your assignment (see [Customizing the environment](#customizing-the-environment)).
3. In GitHub Classroom, create a new assignment and point it at your new repo.
4. Students accept the assignment and open it in Codespaces via the **Code → Codespaces** button.

The first startup of a new Codespace takes 5–10 minutes to set up the virtual machine. Most of this will not happen again when reusing a particular Codespace, although reopening one can take a while during busy times. The first time a Jupyter cell is executed on a particular Codespace instance will cause another 60-second lag. Thereafter, execution may be 2-5 times slower than on a recent-model PC or Mac.

### Option 2: Local devcontainer: medium fuss, less variance in execution time

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop/) and [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

All execution is on the local computer, through a layer of abstraction.

1. Clone your generated repository.
2. Open it in VS Code. When prompted, click **Reopen in Container**. If not prompted, open the Command Palette (`Ctrl/Cmd+Shift+P`) and run **Dev Containers: Reopen in Container**.
3. VS Code will pull the image and open a terminal inside the container with Julia available.

Note that VS Code can open the project folder *locally*, in which case everything behaves as normal files on your computer, or *in container*, which means the files are accessed by a virtual machine running on your computer in an environment that has Julia and all the relevant packages installed. 

Changed and new files will exist *only* on the local computer until pushed to GitHub.

### Option 3: Plain clone: fastest to use, medium hassle to set up

To run locally without a container:

1. [Install Julia](https://julialang.org/downloads/), if it's not installed already.
2. Clone the repository.
3. Within the top-level folder of the project, start Julia:

```bash
julia --project
```

4. Instantiate the environment:

```julia
import Pkg; Pkg.instantiate()
```

This step will download and precompile all packages from scratch, which may take 10–20 minutes on the first run. (If nothing seems to happen, you may have started Julia in the wrong folder in step 3.) Thereafter, importing a package should take just a few seconds, even in new Julia sessions.

To use Julia, you probably will also want to [install Jupyter, VS Code,](https://fncbook.com/setup/) Pluto, or some other development environment. If using Jupyter notebooks, put them within the folder tree of the cloned project.

Changed and new files will exist *only* on the local computer until pushed to GitHub.

### Recommendation

Students who hate installing software more than they hate waiting for computers to respond should use Option 1. Students who already have Docker and VS Code installed may prefer Option 2. Students who don't mind getting their hands a little dirty are advised to use Option 3.

## Customizing the environment

After generating a repo from this template, an instructor will typically want to add assignment notebooks, data files, or scripts to the repo root. They _may_ also want to:

- **Add VS Code extensions** for students by editing `.devcontainer/devcontainer.json`. 
- **Add packages** for the assignment by editing `Project.toml` and running `Pkg.add` locally to update `Manifest.toml`. Students do not need to rebuild the Docker image — `Pkg.instantiate()` runs at Codespace creation and will install any packages not already in the image.

Do not modify `.devcontainer/Dockerfile` in generated assignment repos unless you need a fundamentally different environment. Pull the image as-is and layer changes through `postCreateCommand` or by adding packages to the project.

## Repository structure

```
.
├── .devcontainer/
│   ├── devcontainer.json     # Codespaces/devcontainer configuration
│   └── Dockerfile            # Docker image definition
├── .github/
│   └── workflows/
│       └── build-docker.yml        # Builds and pushes image to GHCR on changes
├── Manifest.toml             # Exact pinned package versions
├── Project.toml              # Package dependencies
└── precompile_workload.jl    # Exercises package code paths during image build
```

## Maintenance

### Updating the Julia version

All version configuration is controlled by a single variable in `.github/workflows/docker.yml`:

```yaml
env:
  JULIA_VERSION: "1.11.9"
```

To update:

1. Change `JULIA_VERSION` to the new version, e.g. `"1.12.0"`.
2. Update the `image` field in `.devcontainer/devcontainer.json` to match:
```json
   "image": "ghcr.io/fncbook/julia-classroom:1.12.0"
```
3. Commit and push to `main`. The workflow will build and push a new image tagged with the new version and also update the `latest` tag.

If you want generated assignment repos to always use the newest image without any manual step, change `devcontainer.json` to use the `latest` tag:

```json
"image": "ghcr.io/fncbook/julia-classroom:latest"
```

The tradeoff is that student environments may differ depending on when their Codespace was first created.

### Updating packages

This ordinarily won't be necessary and probably should be done only at the beginning of a semester, if ever.

1. Update `Project.toml` as needed (add, remove, or change package constraints).
2. Run `julia --project` locally and use `Pkg.update()` or `Pkg.add(...)` to regenerate `Manifest.toml`.
3. If the precompile workload exercises the new packages, update `precompile_workload.jl` accordingly.
4. Commit `Project.toml`, `Manifest.toml`, and `precompile_workload.jl`. The workflow triggers on changes to `Project.toml` and `precompile_workload.jl` and will rebuild the image automatically.

### Triggering a manual rebuild

Go to **Actions → Build and push Julia classroom image → Run workflow** to trigger a build without making a code change.

### Image location

The image is published to the GitHub Container Registry at `ghcr.io/fncbook/julia-classroom` with version number as tag. It is public.