[ -f $HOME/.local/bin ] || mkdir -p $HOME/.local/bin
echo '
export PATH="$HOME/.local/bin:$PATH"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
' >> /github/home/.bashrc
