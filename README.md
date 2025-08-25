# PR Preview Environments (Windows + PowerShell + Jenkins + Minikube)

This repo demonstrates **on-demand Preview Environments per Pull Request** using **Terraform + Kubernetes (Minikube) + Jenkins**, with optional **GitHub Actions** and **Netlify/Vercel** for frontend previews.

## How it works (backend on Minikube)

- **PR opened/synchronized** → Jenkins builds a Docker image tagged with the PR number, then runs Terraform to create:
  - a dedicated **Namespace**: `pr-<PR>`
  - a **Deployment** and **Service**
  - an **Ingress** at `pr-<PR>.$MINIKUBE_IP.nip.io`
- **PR merged/closed** → Jenkins (or the provided GitHub Action) runs Terraform destroy to remove the namespace and all resources.

> Uses `nip.io` (wildcard DNS) so you don’t need real subdomains. Example host: `pr-123.192.168.49.2.nip.io`

## Prereqs (Windows PowerShell)

- Jenkins running locally (you already have it)
- Minikube running locally: `minikube start` \
  and enable ingress: \
  `minikube addons enable ingress`
- Terraform installed and on PATH
- Docker installed. For Minikube to see images you build locally: \
  `& minikube -p minikube docker-env | Invoke-Expression`

## Quick start

1) Start Minikube and enable Ingress:
```powershell
minikube start
minikube addons enable ingress
$env:MINIKUBE_IP = (minikube ip)
```

2) In Jenkins, create a **Multibranch Pipeline** (or a classic pipeline with the included `Jenkinsfile`). Ensure the node has:
- Docker
- Terraform
- Kubectl access to your Minikube cluster (see `jenkins/scripts/set-kubeconfig.ps1`).

3) Ensure the Jenkins job is set to build PRs (if using Multibranch with GitHub source).

4) Open a PR. Jenkins will:
- Build `app` Docker image tagged `pr-<PR>`
- Run Terraform apply with variables: `pr_number`, `image`, `host`
- Post the preview URL in the console logs (and optionally as a GH comment if token configured).

5) Close/Merge the PR. Either:
- Jenkins will auto-detect the close (if configured), or
- The GitHub Action `pr-cleanup.yml` triggers Jenkins `destroy` with the PR number.

## Secrets & tokens (optional)

- If you want **GitHub Actions** to trigger Jenkins remotely on PR close/merge, create secrets:
  - `JENKINS_URL` (e.g., `https://<ngrok-id>.ngrok.io` or your Jenkins public URL)
  - `JENKINS_JOB` (e.g., `pr-previews` if classic freestyle/pipeline job, or a dedicated destroy job)
  - `JENKINS_USER` / `JENKINS_TOKEN` (API token of a Jenkins user)
- If you want Actions to **comment** the preview URL back on PRs, add `GITHUB_TOKEN` (provided by default in Actions).

## Optional frontend previews

- **Netlify**: `netlify.toml` is provided to automatically build PR previews for a frontend under `/frontend` (you can add later).
- **Vercel**: `vercel.json` provided for preview deployments. These run independently from the backend and are optional.

## Repo layout

```
app/                    # sample Node app (shows PR number)
terraform/              # k8s namespace+deploy+service+ingress per PR via Terraform
jenkins/
  Jenkinsfile           # build, apply, destroy logic
  scripts/
    deploy.ps1
    destroy.ps1
    set-kubeconfig.ps1
.github/workflows/
  pr-preview.yml
  pr-cleanup.yml
netlify.toml            # optional Netlify preview config
vercel.json             # optional Vercel preview config
```

---

### Notes

- Ingress class is set to `nginx`. On Minikube, enabling the ingress addon provides this.
- Terraform uses the local kubeconfig; `set-kubeconfig.ps1` ensures Jenkins has it.
- Image pull is from the **local Minikube Docker daemon**; Jenkins builds into Minikube’s Docker by evaluating the env.
