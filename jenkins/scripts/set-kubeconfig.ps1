param(
  [Parameter(Mandatory=$false)][string]$KubeconfigPath = "$env:USERPROFILE\.kube\config"
)
$ErrorActionPreference = "Stop"

if (!(Test-Path $KubeconfigPath)) {
  Write-Error "Kubeconfig not found at $KubeconfigPath"
  exit 1
}
$env:KUBECONFIG = $KubeconfigPath
kubectl config current-context | Out-Null
Write-Host "KUBECONFIG set to $KubeconfigPath"
