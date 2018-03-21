#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}
export HOME=/home/user
echo "Starting with UID : $USER_ID"

if [ ! -f "$HOME/.zshrc" ]; then
  useradd --shell /bin/zsh -u $USER_ID -o -c "" -m user
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
  adduser user docker
  adduser user sudo
  cd $HOME
  # oh my zsh
  # copy dotfiles
  cp -r /root/.config /home/user
  cp -r /root/.zshrc /home/user
  cp -r /root/.tmux.conf /home/user
  cp -r /root/.vim /home/user
  cp -r /root/.oh-my-zsh /home/user
  chown -R user:user /home/user/.*
fi

cd $HOME
exec /usr/sbin/gosu user "$@"
