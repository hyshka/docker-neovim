FROM ubuntu:16.04
MAINTAINER Bryan Hyshka <bryan@hyshka.com>


########################################
# System Stuff
########################################

# Better terminal support
ENV TERM screen-256color
ENV DEBIAN_FRONTEND noninteractive

# Update and install
RUN apt-get update && apt-get install -y \
  bash \
  curl \
  git \
  software-properties-common \
  python-dev \
  python-pip \
  python3-dev \
  python3-pip \
  ctags \
  shellcheck \
  netcat-openbsd \
  locales

# Generally a good idea to have these, extensions sometimes need them
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Add Neovim PPA
RUN add-apt-repository ppa:neovim-ppa/stable
# Run script to add nodejs 6 PPA
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

# Install custom packages
RUN apt-get update && apt-get install -y \
  neovim \
  nodejs


########################################
# Python
########################################

# Install python linting and neovim plugin
RUN pip install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8-naming pep257 isort
RUN pip3 install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8-naming pep257 isort


########################################
# Javscript
########################################

# Setup JS and Sass linting
RUN npm install -g \
  eslint@\^3.17.1 eslint-config-airbnb-base eslint-plugin-import eslint-plugin-vue \
  stylelint@\^7.9.0 stylelint-config-recess-order stylelint-order stylelint-scss \
  stylefmt@\^5.3.2

# Install the eslintrc.js
ADD eslintrc.js /root/.eslintrc.js
# Install the stylelint config
ADD stylelint.config.js /root/stylelint.config.js
# Set Node path to node can resolve globally installed modules
ENV NODE_PATH /usr/lib/node_modules


########################################
# Personalizations
########################################
# Add some aliases
ADD bashrc /root/.bashrc
# Add my git config
ADD gitconfig /etc/gitconfig
# Change the workdir, Put it inside root so I can see neovim settings in finder
WORKDIR /root/app
# Neovim needs this so that <ctrl-h> can work
RUN infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
RUN tic /tmp/$TERM.ti
# Command for the image
CMD ["/bin/bash"]
# Add nvim config. Put this last since it changes often
ADD nvim /root/.config/nvim
# Install neovim Modules
RUN nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
RUN nvim -i NONE -c UpdateRemotePlugins -c quitall > /dev/null 2>&1
# Add flake8 config, don't trigger a long build process
ADD flake8 /root/.flake8
# Add local vim-options, can override the one inside
# ADD vim-options /root/.config/nvim/plugged/vim-options
# Add isort config, also changes often
ADD isort.cfg /root/.isort.cfg
