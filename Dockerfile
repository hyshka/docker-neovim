FROM alpine:edge

# Add the testing repo to get neovim
# RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
# RUN echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

# Install all the needed packages
RUN apk add --no-cache \
	# My Stuff
      bash \
      unibilium \
      # php5 \
      # php5-json \
      # php5-phar \
      # php5-openssl \
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
      # Needed for python pip installs
      musl-dev \
      gcc \
      # Needed for infocmp and tic
      ncurses

# Download composer and move it to new location
# RUN curl -sS https://getcomposer.org/installer | php
# RUN mv composer.phar /usr/local/bin/composer

# Update the path to include composer bins
# ENV PATH "$PATH:/root/.composer/vendor/bin"

# Composer install Code Sniff
# RUN composer global require "squizlabs/php_codesniffer=*"

# Install Symfony 2 coding standard
# RUN composer global require --dev escapestudios/symfony2-coding-standard:~2.0

# Add Symfony 2 coding standard to the phpcs paths
# RUN phpcs --config-set installed_paths /root/.composer/vendor/escapestudios/symfony2-coding-standard

# Install custom linting
# ADD PEARish.xml /root/PEARish.xml

# Install python linting and neovim plugin
RUN python -m ensurepip
RUN pip install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8 pep8-naming pep257 isort
RUN pip3 install neovim jedi flake8 flake8-docstrings flake8-isort flake8-quotes pep8 pep8-naming pep257 isort

# Add isort config
ADD isort.cfg /root/.isort.cfg

# Install nodejs linting
# Install JS linting modules
# Install sass linting
RUN npm install -g \
      eslint@\^3.14.0 eslint-config-airbnb-base eslint-plugin-import eslint-plugin-vue \
      sass-lint@\^1.10.2

# Install the eslintrc.js
ADD eslintrc.js /root/.eslintrc.js

# Install the sass-lint.yaml
ADD sass-lint.yaml /root/.sass-lint.yaml

# Copy over the shellcheck binaries
COPY package/bin/shellcheck /usr/local/bin/
COPY package/lib/           /usr/local/lib/
RUN ldconfig /usr/local/lib

# Download my Neovim Repo
RUN git clone https://github.com/hyshka/nvim.git /root/.config/nvim

# Install neovim Modules
RUN nvim +PlugInstall +qall
RUN nvim +UpdateRemotePlugins +qall

# Add some aliases
ADD bashrc /root/.bashrc

WORKDIR /root/app

# Better terminal support
ENV TERM xterm-256color

# Neovim needs this so that <ctrl-h> can work
RUN infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > /tmp/$TERM.ti
RUN tic /tmp/$TERM.ti

# Command for the image
CMD ["/bin/bash"]
