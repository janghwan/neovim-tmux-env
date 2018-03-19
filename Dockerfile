FROM ubuntu:16.04

# Locales
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
RUN apt-get update && apt-get install -y locales && locale-gen en_US.UTF-8

# Colors and italics for tmux
COPY xterm-256color-italic.terminfo /root
RUN tic /root/xterm-256color-italic.terminfo
ENV TERM=xterm-256color-italic

# Common packages
RUN apt-get update && apt-get install -y \
      build-essential \
      curl \
      git  \
      iputils-ping \
      jq \
      libncurses5-dev \
      libevent-dev \
      net-tools \
      netcat-openbsd \
      rubygems \
      ruby-dev \
      silversearcher-ag \
      socat \
      software-properties-common \
      tmux \
      tzdata \
      wget \
      gosu \
      zsh
RUN chsh -s /usr/bin/zsh

# ohmyzsh
#RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

# Install docker
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D &&\
      echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list &&\
      apt-get install -y apt-transport-https &&\
      apt-get update &&\
      apt-get install -y docker-engine
RUN  curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.19.0/docker-compose-$(uname -s)-$(uname -m)" &&\
     chmod +x /usr/local/bin/docker-compose

RUN add-apt-repository ppa:longsleep/golang-backports
RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update
# Install go
RUN apt-get install -y golang-1.8-go
# Install neovim
RUN apt-get install -y neovim
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim

# Install tmux
WORKDIR /usr/local/src
RUN wget https://github.com/tmux/tmux/releases/download/2.6/tmux-2.6.tar.gz
RUN tar xzvf tmux-2.6.tar.gz
WORKDIR /usr/local/src/tmux-2.6
RUN ./configure
RUN make 
RUN make install
RUN rm -rf /usr/local/src/tmux*

RUN apt-get install -y \
      autoconf \
      automake \
      cmake \
      g++ \
      libtool \
      libtool-bin \
      pkg-config \
      python3 \
      python3-pip \
      unzip

#RUN pip3 install --upgrade pip &&\ 
#    pip3 install --user neovim jedi mistune psutil setproctitle
#WORKDIR /usr/local/src
#RUN git clone --depth 1 https://github.com/neovim/neovim.git
#WORKDIR /usr/local/src/neovim
#RUN git fetch --depth 1 origin tag v0.2.1
#RUN git reset --hard v0.2.1
#RUN make CMAKE_BUILD_TYPE=RelWithDebInfo
#RUN make install
#RUN rm -rf /usr/local/src/neovim

# nvm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

WORKDIR /root
COPY .vimrc /root/.config/nvim/init.vim
COPY .zshrc /root
COPY .tmux.conf /root

RUN vim +PluginInstall +qall --headless

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["zsh"]
