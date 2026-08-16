path=(
  "${KREW_ROOT:-$HOME/.krew}/bin"
  $path
)

# Aliases
alias k=kubectl
alias kx="kubectl ctx"
alias kn="kubectl ns"
alias k8s-node-view="eks-node-viewer -extra-labels instance-types,topology.kubernetes.io/zone -resources cpu,memory -disable-pricing"
alias kw='kubectl config view --output json | jq '\''. as $cfg | {name: $cfg["current-context"], namespace: ($cfg.contexts[] | select(.name == $cfg["current-context"]).context.namespace)}'\'' | yq -P'