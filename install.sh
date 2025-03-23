#!/bin/bash

install_config() {
  local -r source_file=$(pwd)/.tmux.conf
  local -r destination_file=$HOME/.tmux.conf
  ln -s "$source_file" "$destination_file"
  echo "Install success, please press Ctrl+r in tmux mode to reload config"
}

# run install
install_config
