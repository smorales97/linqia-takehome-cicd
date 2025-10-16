# EN - CI/CD – Technical Design (Linqia Take-Home Assignment)

## Project Objectives

- Validate code quality (lint), tests, and coverage on Python **3.10**, **3.11**, and **3.12**.
- Build and publish a **Docker image** tagged by branch to a **public registry (GHCR)**.
- Run a **simulated Continuous Deployment (CD)** workflow that executes only if **CI passes**, pulling and running the published image.
- Automatically comment on the **Pull Request (PR)** with CI/CD results and the image reference.

---

## Pipeline Architecture

This project uses two GitHub Actions workflows contained in a **public forked repository**:

### 🧩 Continuous Integration (CI)
**Trigger:** `on: [push, pull_request]` to `main`

#### Steps
1. **Python Version Matrix**
   - Executes on Python 3.10, 3.11, and 3.12 using a job matrix.

2. **Linter: Ruff**
   - Runs static analysis and code formatting checks.
   - Uses `--fix` for auto-fixable issues and fails on remaining lint errors.

3. **Tests + Coverage**
   - Uses `pytest` and `pytest-cov` to run unit tests and generate:
     - `coverage.xml`
     - `.coverage`
     - `junit.xml`
   - Displays test results in the PR summary.
   - Includes a **quality gate**: fails if coverage < 90%.

4. **Build & Push Docker Image**
   - Builds an image using branch-based tagging:
     ```
     ghcr.io/<owner>/<repo>:<sanitized-branch>
     ```
   - Pushes the image to **GitHub Container Registry (GHCR)**.

5. **Upload Artifacts**
   - Uploads `coverage.xml`, `.coverage`, `junit.xml`, and `image.txt` (with image reference).

6. **Security Scan (Bonus)**
   - Runs a **Trivy** scan on the built image for OS/library vulnerabilities (non-blocking).

7. **PR Comment (Automated Summary)**
   - Posts a CI summary comment including:
     - Link to the public Docker image on GHCR
     - Test results (passed, failed, skipped)
     - Coverage percentage
     - Artifact download links
     - Run link for reviewers

#### Additional Enhancements
- **Dependency Cache**: pip caching across runs for faster builds.
- **Coverage enforcement** with a configurable threshold.
- **Image scanning** for awareness of vulnerabilities.

---

### 🚀 Continuous Deployment (CD)
**Trigger:** `on: workflow_run` → runs only after CI completes successfully.

#### Steps
1. **Find PR Context**
   - Identifies the PR associated with the `head_sha` of the CI run.

2. **Compute Image Reference**
   - Derives and sanitizes the branch name:
     ```
     refs/pull/7/merge → 7-merge
     feature/add-solution → feature-add-solution
     ```
   - Constructs:
     ```
     ghcr.io/<owner>/<repo>:<sanitized-branch>
     ```

3. **Pull Image from GHCR**
   - Authenticates using the default `GITHUB_TOKEN` and pulls the image built by CI.

4. **Simulated Deployment**
   - Runs the container locally within the GitHub runner:
     ```bash
     docker run --rm ghcr.io/<repo>:<branch> 2 3
     ```
   - Executes the CLI entrypoint (`python -m sample_app 2 3`) defined in `__main__.py`.

5. **PR Comment**
   - Posts a comment on the PR indicating the deployment status, including:
     - ✅ Success message
     - Image reference and tag used
     - Command executed

---

## Rationale and Trade-offs

| Design Choice | Rationale |
|----------------|------------|
| **GHCR for image hosting** | Uses `GITHUB_TOKEN` without requiring extra credentials. Public visibility for reviewers. |
| **workflow_run trigger** | Clean separation of CI/CD pipelines while maintaining dependency chaining. |
| **Ruff as linter** | Fast, modern, and simple configuration. Easily replaceable by `flake8` or `pylint`. |
| **Trivy scan** | Adds DevSecOps value without blocking the pipeline; could later enforce severity thresholds. |
| **Artifact uploads** | Ensures reviewers can download results for inspection. |
| **Automated PR comments** | Provides a clear summary of CI/CD status directly in GitHub’s interface. |

---

## Future Improvements

- ♻️ **Reusable workflows** to apply the same CI/CD templates across multiple repositories.
- 🧾 **SBOM generation** (via [Syft](https://github.com/anchore/syft)) and **image signing** (via [cosign](https://github.com/sigstore/cosign)).
- 🌐 **Environment-based deployments**:
  - `main` → production
  - `develop` → staging
  - PR branches → test environments (preview).
- 📊 **Enhanced PR reporting**:
  - Add GitHub badges for build/test/coverage status.
  - Include GHCR digest links and Trivy scan summary.
- 🛡️ **Failing Trivy on high/critical vulnerabilities** once proper thresholds are defined.

---

## References

- **GitHub Actions** Documentation → [https://docs.github.com/actions](https://docs.github.com/actions)
- **GHCR (GitHub Container Registry)** → [https://docs.github.com/packages](https://docs.github.com/packages)
- **Trivy Security Scanner** → [https://github.com/aquasecurity/trivy](https://github.com/aquasecurity/trivy)
- **Ruff Linter** → [https://github.com/astral-sh/ruff](https://github.com/astral-sh/ruff)

---

**Author:** *[Santiago Morales]*
**Repository:** [https://github.com/smorales97/linqia-takehome-cicd](https://github.com/smorales97/linqia-takehome-cicd)
**Submission:** Linqia CI/CD Specialist Take-Home Assignment

----------------------------------------------------------------------------------------------------------------------------------------------

# CI/CD – Diseño Técnico (Prueba Linqia Take-Home)  ES

## Objetivos del Proyecto

- Validar la calidad del código (lint), las pruebas y la cobertura en Python **3.10**, **3.11** y **3.12**.
- Construir y publicar una **imagen Docker** etiquetada por rama en un **registro público (GHCR)**.
- Ejecutar un flujo de **Despliegue Continuo (CD)** simulado que solo se ejecute si el **CI aprueba**, extrayendo y ejecutando la imagen publicada.
- Comentar automáticamente en el **Pull Request (PR)** con los resultados del CI/CD y la referencia de la imagen.

---

## Arquitectura del Pipeline

Este proyecto utiliza dos workflows de GitHub Actions dentro de un **repositorio público (fork)**:

### 🧩 Integración Continua (CI)
**Trigger:** `on: [push, pull_request]` a `main`

#### Pasos

1. **Matriz de versiones de Python**
   - Se ejecuta en Python 3.10, 3.11 y 3.12 utilizando una matriz de trabajos.

2. **Linter: Ruff**
   - Realiza análisis estático y formateo del código.
   - Usa `--fix` para corregir automáticamente los errores posibles y falla si quedan pendientes.

3. **Pruebas + Cobertura**
   - Usa `pytest` y `pytest-cov` para ejecutar pruebas unitarias y generar:
     - `coverage.xml`
     - `.coverage`
     - `junit.xml`
   - Muestra los resultados de las pruebas en el comentario del PR.
   - Incluye una **puerta de calidad (quality gate)**: el job falla si la cobertura es menor al 90%.

4. **Construcción y publicación de la imagen Docker**
   - Construye la imagen usando una etiqueta basada en la rama:
     ```
     ghcr.io/<owner>/<repo>:<branch-sanitizada>
     ```
   - Publica la imagen en **GitHub Container Registry (GHCR)**.

5. **Carga de artefactos**
   - Sube `coverage.xml`, `.coverage`, `junit.xml` e `image.txt` (con la referencia de la imagen).

6. **Escaneo de seguridad (bonus)**
   - Ejecuta un escaneo **Trivy** sobre la imagen construida para detectar vulnerabilidades (solo informativo).

7. **Comentario automático en el PR**
   - Publica un resumen con:
     - Enlace a la imagen Docker pública en GHCR
     - Resultados de pruebas (aprobadas, fallidas, omitidas)
     - Porcentaje de cobertura
     - Enlace de descarga a los artefactos
     - Enlace al run de Actions para revisión

#### Mejoras adicionales
- **Cacheo de dependencias** de pip para acelerar los builds.
- **Umbral de cobertura configurable** (fail_under = 90%).
- **Escaneo de imagen** no bloqueante con Trivy.

---

### 🚀 Despliegue Continuo (CD)
**Trigger:** `on: workflow_run` → se ejecuta solo después de que CI finaliza con éxito.

#### Pasos

1. **Identificación del PR**
   - Localiza el Pull Request asociado al `head_sha` del run exitoso de CI.

2. **Cálculo de la referencia de imagen**
   - Deriva y sanitiza el nombre de la rama:
     ```
     refs/pull/7/merge → 7-merge
     feature/add-solution → feature-add-solution
     ```
   - Construye la referencia completa:
     ```
     ghcr.io/<owner>/<repo>:<branch-sanitizada>
     ```

3. **Extracción de la imagen desde GHCR**
   - Se autentica con `GITHUB_TOKEN` y descarga la imagen publicada por CI.

4. **Despliegue simulado**
   - Ejecuta el contenedor dentro del runner de GitHub:
     ```bash
     docker run --rm ghcr.io/<repo>:<branch> 2 3
     ```
   - Ejecuta el CLI `python -m sample_app 2 3` definido en `__main__.py`.

5. **Comentario en el PR**
   - Publica un comentario indicando el estado del despliegue, incluyendo:
     - ✅ Mensaje de éxito
     - Referencia de la imagen utilizada
     - Comando ejecutado

---

## Fundamentación y Decisiones de Diseño

| Elección | Justificación |
|-----------|----------------|
| **GHCR para alojar imágenes** | Permite usar `GITHUB_TOKEN` sin credenciales adicionales. Ofrece visibilidad pública para los revisores. |
| **workflow_run como trigger de CD** | Desacopla los pipelines de CI/CD, pero mantiene dependencia entre ellos. |
| **Ruff como linter** | Es rápido, moderno y fácil de configurar (puede reemplazarse por flake8 o pylint). |
| **Trivy como escáner** | Aporta valor DevSecOps sin bloquear el pipeline; se pueden aplicar umbrales de severidad más adelante. |
| **Carga de artefactos** | Facilita la descarga y revisión de resultados por parte del evaluador. |
| **Comentarios automáticos en PR** | Ofrecen visibilidad inmediata del estado del pipeline directamente en GitHub. |

---

## Posibles Mejoras Futuras

- ♻️ **Workflows reutilizables** para aplicar la misma plantilla CI/CD a varios repositorios.
- 🧾 **Publicación de SBOM** (con [Syft](https://github.com/anchore/syft)) y **firma de imágenes** (con [cosign](https://github.com/sigstore/cosign)).
- 🌐 **Despliegues por entorno**:
  - `main` → producción
  - `develop` → staging
  - ramas de PR → entornos de prueba (preview).
- 📊 **Reportes enriquecidos en PR**:
  - Badges de estado (build/test/coverage).
  - Enlaces al digest de GHCR y resumen del escaneo Trivy.
- 🛡️ **Hacer fallar Trivy** ante vulnerabilidades **High/Critical** con umbrales definidos.

---

## Referencias

- **GitHub Actions** → [https://docs.github.com/actions](https://docs.github.com/actions)
- **GHCR (GitHub Container Registry)** → [https://docs.github.com/packages](https://docs.github.com/packages)
- **Trivy Security Scanner** → [https://github.com/aquasecurity/trivy](https://github.com/aquasecurity/trivy)
- **Ruff Linter** → [https://github.com/astral-sh/ruff](https://github.com/astral-sh/ruff)

---

**Autor:** *[Santiago Morales]*
**Repositorio:** [https://github.com/smorales97/linqia-takehome-cicd](https://github.com/smorales97/linqia-takehome-cicd)
**Entrega:** Linqia CI/CD Specialist Take-Home Assignment
