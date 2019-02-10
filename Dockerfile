FROM debian:sid
MAINTAINER Bryan Hyshka <bryan@hyshka.com>

########################################
# System Stuff
########################################

# Better terminal support
ENV TERM screen-256color
ENV DEBIAN_FRONTEND noninteractive

# Update and install
RUN apt-get update && apt-get install -y \
  htop \
  bash \
  git \
  curl \
  wget \
  netcat-openbsd \
  silversearcher-ag \
  shellcheck \
  python \
  python-pip \
  python3 \
  python3-pip \
  nodejs \
  npm \
  # ranger + optional deps
  ranger highlight \
  # ctags-universal
  universal-ctags

# Generally a good idea to have these, extensions sometimes need them
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Neovim spellchecker files
RUN mkdir -p '/root/.local/share/nvim/site/spell'
RUN curl 'http://ftp.vim.org/pub/vim/runtime/spell/en.utf-8.spl' -o '/root/.local/share/nvim/site/spell/en.utf-8.spl'
RUN curl 'http://ftp.vim.org/pub/vim/runtime/spell/en.utf-8.sug' -o '/root/.local/share/nvim/site/spell/en.utf-8.sug'


########################################
# Python
########################################

# Install python linting and neovim plugin
RUN pip install neovim
RUN pip3 install neovim black


########################################
# Javscript
########################################

# Set Node path to node can resolve globally installed modules
ENV NODE_PATH /usr/lib/node_modules

# TODO TEMP FIX: Something in prettier needs this or it blows up
# Ref: https://github.com/npm/uid-number/issues/3
RUN npm config set unsafe-perm true

# Setup JS and Sass linting
RUN npm install -g \
  neovim \
  prettier

# TODO: setup new linters
# Stylelint
# eslint-prettier config
# vls for vue?


########################################
# Personalizations
########################################
# Add some aliases
ADD bashrc /root/.bashrc
# Add my git config
ADD gitconfig /etc/gitconfig
# Change the workdir, Put it inside root so I can see neovim settings in finder
WORKDIR /root/app

# Re-construct terminfo file
# Neovim needs this so that <ctrl-h> can work
# Requires: ncurses, sed
RUN infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
RUN tic /tmp/$TERM.ti

# Command for the image
CMD ["/bin/bash"]

# Add nvim config. Put this last since it changes often
ADD nvim /root/.config/nvim

# Install neovim Modules
RUN nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
# Compile YouCompleteMe and install tsserver for js completion
# RUN cd /root/.config/nvim/plugged/YouCompleteMe && python3 install.py --ts-completer
# RUN cd /root/.config/nvim/plugged/YouCompleteMe/third_party/ycmd && npm install -g --prefix third_party/tsserver typescript

# Add local vim-options, can override the one inside
ADD vim-options /root/.config/nvim/plugged/vim-options

# Add ranger config
ADD rc.conf /root/.config/ranger/rc.conf
