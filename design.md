# CI/CD – Technical Design (Linqia Take-Home)

# Project Objectives

- Validate code quality (lint), tests, and coverage on Python 3.10/3.11/3.12.
- Build and publish a Docker image tagged by branch to a public repository (GHCR).
- Run a simulated CD workflow that executes only if CI passes, pulling and running the published image.

Automatically comment on the PR with CI/CD results and the image reference.

Pipeline Architecture

A public repository (fork) containing two GitHub Actions workflows:

CI (on: push/PR to main)

Python Matrix: 3.10 / 3.11 / 3.12.

Linter: Ruff (fast and optionally auto-fixable — only runs as a check in CI).

Tests + Coverage: pytest + pytest-cov → generates coverage.xml and console output.

Quality Gate (bonus): fail_under = 90% (configurable) – job fails if coverage is below threshold.

Build & Push Docker: builds ghcr.io/<owner>/<repo>:<branch> and publishes it to GHCR.

Artifacts: uploads coverage.xml, .coverage, and junit.xml for review.

PR Comment: posts a summary including coverage, artifacts, and image reference.

Extras (bonus):

Cache pip dependencies to speed up builds.

Image Security Scan (Trivy) as an informational job.

CD (on: workflow_run: CI success)

Locates the PR from the successful CI head_sha.

Pulls the image from ghcr.io/<owner>/<repo>:<branch>.

Simulated deployment: runs the container via the CLI python -m sample_app 2 3 (see __main__.py).

PR Comment: posts the deployment status and image reference.

Rationale and Trade-offs

GHCR avoids the need for extra credentials; GITHUB_TOKEN with packages permissions is sufficient.

workflow_run decouples CI and CD but requires mapping the commit SHA to the open PR.

Ruff chosen for speed and simplicity (could be swapped for flake8/pylint).

Trivy does not fail the pipeline by default (report only); in production, severity thresholds could be enforced.

Future Improvements

Reusable workflows and templates for multiple repositories.

SBOM publishing (Syft) and image signing (cosign).

Environment-based branching (main→prod, develop→staging) and real deployments to ECS/K8s.

Enriched PR reports (badges, GHCR digest links, etc.).