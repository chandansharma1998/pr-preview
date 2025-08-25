param(
  [Parameter(Mandatory=$true)][string]$PrNumber,
  [Parameter(Mandatory=$false)][string]$KubeconfigPath = "$env:USERPROFILE\.kube\config"
)
$ErrorActionPreference = "Stop"

./jenkins/scripts/set-kubeconfig.ps1 -KubeconfigPath $KubeconfigPath

Push-Location terraform
# Recompute host
$MINIKUBE_IP = $env:MINIKUBE_IP
if ([string]::IsNullOrEmpty($MINIKUBE_IP)) { $MINIKUBE_IP = (minikube ip) }
$HOST="pr-$PrNumber.$MINIKUBE_IP.nip.io"

terraform destroy -auto-approve -input=false `
  -var pr_number="$PrNumber" `
  -var image="pr-preview-app:pr-$PrNumber" `
  -var host="$HOST"
Pop-Location

Write-Host "Destroyed environment for PR #$PrNumber"
