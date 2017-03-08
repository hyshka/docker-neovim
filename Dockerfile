FROM alpine:edge

########################################
# System Stuff
########################################

# Install all the needed packages
RUN apk add --no-cache \
  # My Stuff
      bash \
      unibilium \
      curl \
      git \
      ack \
      python \
      python-dev \
      python3 \
      python3-dev \
      nodejs \
      neovim \
      neovim-doc \
      ctags \
      vimdiff \
      # Needed for python pip installs
      musl-dev \
      gcc \
      # Needed for infocmp and tic
      ncurses \
      # Needed for clipboard
      xclip


########################################
# Python
########################################

# Install python linting and neovim plugin
RUN python -m ensurepip
RUN pip install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8 pep8-naming pep257 isort
RUN pip3 install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8 pep8-naming pep257 isort
# Add flake8 config
ADD flake8 /root/.flake8


########################################
# Shellcheck
########################################

# Copy over the shellcheck binaries
COPY package/bin/shellcheck /usr/local/bin/
COPY package/lib/           /usr/local/lib/
RUN ldconfig /usr/local/lib


########################################
# Javscript
########################################
# Install nodejs linting
# Install JS linting modules
# Install sass linting
RUN npm install -g \
      eslint@\^3.17.1 eslint-config-airbnb-base eslint-plugin-import eslint-plugin-vue \
      sass-lint@\^1.10.2
# Install the eslintrc.js
ADD eslintrc.js /root/.eslintrc.js
# Install the sass-lint.yaml
ADD sass-lint.yaml /root/.sass-lint.yaml


########################################
# Personalizations
########################################
# Add some aliases
ADD bashrc /root/.bashrc
# Add my git config
ADD gitconfig /root/.gitconfig
# Change the workdir, Put it inside root so I can see neovim settings in finder
WORKDIR /root/app
# Better terminal support
ENV TERM screen-256color
# Neovim needs this so that <ctrl-h> can work
RUN infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
RUN tic /tmp/$TERM.ti
# Command for the image
CMD ["/bin/bash"]
# Add nvim config. Put this last since it changes often
ADD nvim /root/.config/nvim
# Install neovim Modules
RUN nvim +PlugInstall +qall
RUN nvim +UpdateRemotePlugins +qall
# Add local vim-options, can override the one inside
ADD vim-options /root/.config/nvim/plugged/vim-options
# Add isort config, also changes often
ADD isort.cfg /root/.isort.cfg
