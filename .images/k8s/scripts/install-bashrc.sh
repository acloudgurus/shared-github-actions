[ -f $HOME/.local/bin ] || mkdir -p $HOME/.local/bin
echo '
export PATH="$HOME/.local/bin:$PATH"
' >> /github/home/.bashrc
