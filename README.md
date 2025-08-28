# Linqia CI/CD Specialist Take-Home Assignment

Welcome! Your task is to demonstrate your CI/CD skills by creating and integrating GitHub Actions workflows in this project.

You may use **GenAI** and **3rd-party actions** to help, but be prepared to discuss your approach in detail during your technical interview.

Please be sure to read and understand all directions before beginning your work. For the most part, the requirements are open ended and you can solve them however you wish. 

Good luck and have fun!

---

## Project Overview

This project contains some sample python code and unit tests. Your goal is to build a small CICD pipeline around this using the requirements below.

Goals:
* Design and **plan your CI/CD pipeline architecture** as a technical spec or design doc. This should demonstrate your ability to plan a complete pipeline solution and serve as a specification that guides your implementation.
* Build a **CI workflow** that validates code quality, tests, coverage, and builds a Docker image to push to a public repo.
* Build a **CD workflow** that pulls your image from a public repo and mimicks deploying the image, only if CI passes.
* Submit your work as a **Pull Request on your fork**. Don't PR against the Linqia source repo.

Please include and merge any additional files, scripts, or edits to your forked repo (branch rules, secrets, etc.) that your pipeline requires.

Target effort: **\~2–3 hours**

---

## Directions

### 1. Fork & Setup

* Fork this repo and clone it locally.
* Make the repo public on GitHub so that you can share your work when complete.

---

### 2. Plan and Document Your Work

Add a file named **`design.md`** in the repo root:

* Document your plans for the CI/CD pipeline as a technical spec or design document.
* Be sure to include modules, quality gates, or charts so that another person can understand why and how you designed this pipeline.
* You can also include extra information like:

  * Your approach and reasoning.
  * Trade-offs or limitations.
  * Improvements you’d make with more time.

---

### 3. Continuous Integration (CI) Workflow

Your first workflow (`CI`) should follow GitHub Actions' best practices and will:

**Required**

* Trigger on **push** and **pull requests** to `main` branch.
* Validate and test **multiple Python versions** ( 3.10, 3.11, 3.12)
* Run a linter of your choice.
* Run unit tests and generate a coverage report.
* Build a Docker image tagged with the GitHub branch ref.
* Push the Docker image to a public repo of your choice.
* Upload test results and coverage as **artifacts** for reviewers.
* Post a **PR comment** with:

  * The link to the uploaded image on the public repo
  * Test results
  * Coverage percentage
  * Artifact download links

**Bonus**

* Cache dependencies to speed up runs.
* Add a security scan for the image.
* Enforce a coverage threshold.

---

### 4. Continuous Deployment (CD) Workflow

Your second workflow (`CD`) should:

**Required**

* Trigger **only after a successful CI run**.
* Pull the previously built image from the public repo.
* Mock or mimic a deployment by running the Docker image in GitHub Actions (See `__main__.py` for usage instructions)
* Post a comment on the PR explaining the status of the deployment.

---

### 5. Submit as a Pull Request

* Open a PR on your fork (not against the source repo).
* Ensure workflows run automatically.
* Verify artifacts are uploaded.
* Make sure `design.md` is included.
* Share the PR link as your submission.

---

## What We Expect From Your Project

* A passing CI workflow with artifacts and a built Docker image uploaded to a public repo.
* A CD workflow that runs only after a successful CI run and pulls the previously built Docker image.
* PR comments summarizing results of the associated workflows.
* Clear documentation and plan in `design.md`.

---

## Sample Project Instructions

This repo contains a minimal Python package:

* `sample_app/functions.py` → simple `add(a, b)` function.
* CLI: `python -m sample_app 2 3` prints `5`.
* Unit tests in `tests/`.