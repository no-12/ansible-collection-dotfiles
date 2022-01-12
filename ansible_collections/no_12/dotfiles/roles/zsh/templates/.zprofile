{% if is_macos %}
export PATH="$PATH:$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
eval "$(/opt/homebrew/bin/brew shellenv)"
{% endif %}
