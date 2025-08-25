param(
  [Parameter(Mandatory=$true)][string]$PrNumber,
  [Parameter(Mandatory=$true)][string]$Image,
  [Parameter(Mandatory=$false)][string]$KubeconfigPath = "$env:USERPROFILE\.kube\config"
)
$ErrorActionPreference = "Stop"

& minikube -p minikube docker-env | Invoke-Expression

# Ensure kubeconfig
./jenkins/scripts/set-kubeconfig.ps1 -KubeconfigPath $KubeconfigPath

$MINIKUBE_IP = $env:MINIKUBE_IP
if ([string]::IsNullOrEmpty($MINIKUBE_IP)) { $MINIKUBE_IP = (minikube ip) }
$HOST="pr-$PrNumber.$MINIKUBE_IP.nip.io"

Push-Location terraform
terraform init -input=false
terraform apply -auto-approve -input=false `
  -var pr_number="$PrNumber" `
  -var image="$Image" `
  -var host="$HOST"
Pop-Location

Write-Host "Preview ready: http://$HOST/"
