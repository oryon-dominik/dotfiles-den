#!/bin/sh

# set environment variables
export DOTFILES=~/.dotfiles
export PYENV_ROOT=~/.pyenv
export PYTHON_VERSION=3.9.1

## install required software
# update first
sudo apt update
sudo apt upgrade

# htop
sudo apt install -y htop

# Install required packages, including git (for the plugins) and fzf for completion
sudo apt install -y software-properties-common git hub git-flow fzf
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install -y fish
# for fish-motd:
sudo apt install -y fortune-mod fortune-anarchism lolcat

# clone the dotfiles repository
mkdir -p ~/.dotfiles
git -C ~/.dotfiles pull || git clone https://github.com/oryon-dominik/dotfiles.git ~/.dotfiles

# message of the day
sudo ln -sfv ~/.dotfiles/ubuntu/motd/motd /etc/
# We don't need the help text
sudo rm --force /etc/update-motd.d/10-help-text
# And we deactivate the dynamic news
sudo sed -i -e 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news

# setup fish
mkdir -p ~/.config && mkdir -p ~/.config/fish && mkdir -p ~/.config/fish/functions

ln -sfv ~/.dotfiles/ubuntu/home/.config/fish/config.fish ~/.config/fish/config.fish
ln -sfv ~/.dotfiles/ubuntu/home/.config/fish/aliases.fish ~/.config/fish/aliases.fish
ln -sfv ~/.dotfiles/ubuntu/home/.config/fish/functions/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish
ln -sfv ~/.dotfiles/ubuntu/home/.config/fish/functions/wsl_config.fish ~/.config/fish/functions/wsl_config.fish
ln -sfv ~/.dotfiles/ubuntu/home/.config/fish/functions/last_command_as_sudo.fish ~/.config/fish/functions/last_command_as_sudo.fish
ln -sfv ~/.dotfiles/ubuntu/home/.config/fish/functions/xserve.fish ~/.config/fish/functions/xserve.fish

# create some dirs
mkdir -p ~/projects
mkdir -p ~/.virtualenvs

# symlink all the configs from ubuntu/home
ln -sfv ~/.dotfiles/ubuntu/home/.bash_profile ~
ln -sfv ~/.dotfiles/ubuntu/home/.bash_aliases ~
ln -sfv ~/.dotfiles/ubuntu/home/.bash_logout ~
ln -sfv ~/.dotfiles/ubuntu/home/.bash_profile ~
ln -sfv ~/.dotfiles/ubuntu/home/.bashrc ~
ln -sfv ~/.dotfiles/ubuntu/home/.profile ~
ln -sfv ~/.dotfiles/ubuntu/home/.gitconfig ~
# htop
ln -sfv ~/.dotfiles/ubuntu/home/.config/htoprc ~/.config/

# install vim-plugins
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install docker
sudo apt install -y docker.io
# sudo systemctl start docker
sudo systemctl enable docker

if grep --quiet microsoft /proc/version; then
    #--WSL----
    :
else
    # "native linux"
    :
fi

## pyenv
# we need a c compiler & other dependencies
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

sudo rm -rf ~/.pyenv
sudo curl https://pyenv.run | bash

# Install python
pyenv update
# then install your desired python (pyenv install --list)
# this may take a while!
pyenv install $PYTHON_VERSION
# show if everthing is right
pyenv global $PYTHON_VERSION
pyenv versions
pyenv rehash
python -m pip install --upgrade pip

# And poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
source $HOME/.poetry/env
# set the path inline with virtualfish
poetry config virtualenvs.path ~/.virtualenvs/

python -m pip install --user virtualenvwrapper

# install pipx
python -m pip install --user pipx
python -m pipx ensurepath

# yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

# add /bin/fish to /etc/shells
sudo sh -c "echo /bin/fish >> /etc/shells"

# activate fish-shell
fish -i
# and add poetry & pyenv to the path
set -U PYENV_ROOT $HOME/.pyenv
set -U fish_user_paths /usr/local/bin /sbin $HOME/.poetry/bin $HOME/.local/bin $PYENV_ROOT/bin $PYENV_ROOT/shims (yarn global bin) $fish_user_paths

# add fisher and fish plugins
curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish

# To add extended command-completion, async prompt, gitnow & dracula theme & pyenv
fisher install jethrokuan/fzf
# fisher add acomagu/fish-async-prompt  ## possibly broken
fisher install joseluisq/gitnow
fisher install dracula/fish
fisher install daenney/pyenv

# for fish we already installed the pyenv plugin,
# but we have to fix it, since it's a little deprecated
ln -sfv ~/.dotfiles/ubuntu/home/.config/fish/functions/pyenv.fish ~/.config/fish/functions/

# And virtualfish (virtualenvwrapper for fish), including plugins
python -m pip install virtualfish
mkdir -p ~/.config/fish/conf.d
touch ~/.config/fish/conf.d/virtualfish-loader.fish
# to activate the vf-command
eval (python -m virtualfish)
vf install
vf addplugins compat_aliases

set -U VIRTUAL_ENV_DISABLE_PROMPT true

# change the shell to fish
sudo chsh --shell /bin/fish "$USER"
