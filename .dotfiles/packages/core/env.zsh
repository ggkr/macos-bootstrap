export EDITOR='vim'
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=101"

path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  $path
)

# Aliases
alias sudo='sudo '
alias watch='watch '
alias timestamp='date +"%Y%m%d%H%M%S"'
