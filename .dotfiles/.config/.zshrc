typeset -U path fpath

export XDG_CONFIG_HOME="$HOME/.config"
ZSH_CONFIG="$XDG_CONFIG_HOME/zsh"

# Source enabled package environment/path configs
for env_file in $ZSH_CONFIG/env.d/*.zsh(N); do
  source "$env_file"
done

# Initialize Antidote plugin manager (Homebrew)
source "$(brew --prefix)/share/antidote/antidote.zsh"
antidote load "$ZSH_CONFIG/.zsh_plugins.txt"

# Cursor / VS Code integrated terminal (xterm.js): Option+arrow sends CSI; map to word motion.
# Complements terminal.integrated.enableKittyKeyboardProtocol=false in Cursor settings.
bindkey '\e[1;3D' backward-word
bindkey '\e[1;3C' forward-word

# complete -W "$(awk 'FNR > 1 {print $1}' ~/.aws/accounts)" okta_assume_role.sh
# complete -C "$(which aws_completer)" aws

fpath=(
  $ZSH_CONFIG/completions
  $ZSH_CONFIG/functions
  $fpath
)

# 3. Autoload custom functions (0ms startup overhead)
autoload -Uz $ZSH_CONFIG/functions/*(N:t)

# 4. Initialize completion system with dump caching
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.m+1) ]]; then
  compinit -d ~/.zcompdump
else
  compinit -C -d ~/.zcompdump
fi

if [ -f $XDG_CONFIG_HOME/local_profile ]; then # source profiles that are specific to this station and should not be part of bootstrap git repo
    source $XDG_CONFIG_HOME/local_profile
fi

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh" # compatiale for intel cpu
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh" # compatibale for silicon cpu

# should use brew to install gcp and then can rely on already imported bash_completion.sh:
# # The next line updates PATH for the Google Cloud SDK.
# if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
# # The next line enables shell command completion for gcloud.
# if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# Initialize Starship prompt (must be last)
eval "$(starship init zsh)"
