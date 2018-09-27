FROM nlknguyen/alpine-shellcheck
# Reset entrypoint from alpine-shellcheck image
ENTRYPOINT []

MAINTAINER Bryan Hyshka <bryan@hyshka.com>


########################################
# System Stuff
########################################

# Better terminal support
ENV TERM screen-256color

ENV BUILD_TOOLS "automake autoconf make g++"

# Update and install
RUN apk --update add \
  ${BUILD_TOOLS} \
  bash \
  git \
  curl \
  sed \
  less \
  ncurses \
  file \
  # fzf requirement
  findutils \
  highlight \
  python2 \
  python2-dev \
  py2-pip \
  python3 \
  python3-dev \
  ctags \
  netcat-openbsd \
  ack \
  grep \
  the_silver_searcher \
  neovim \
  nodejs

# Install ranger
# Optional deps: less, file, highlight
RUN git clone https://github.com/ranger/ranger.git && cd ranger && make install && cd .. && rm -rf ranger/
# Disable mouse support: https://bugs.alpinelinux.org/issues/6839
RUN sed -i '156s/.*/set mouse_enabled false/' /usr/lib/python2.7/site-packages/ranger/config/rc.conf

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

# Setup JS and Sass linting
RUN npm install -g \
  neovim \
  prettier


########################################
# Clean up
########################################
RUN apk del ${BUILD_TOOLS}
RUN rm -fr /var/apk/caches


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

# # Install neovim Modules
RUN nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
RUN nvim -i NONE -c UpdateRemotePlugins -c quitall > /dev/null 2>&1
