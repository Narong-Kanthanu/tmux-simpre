#!/bin/bash

install_config() {
  local -r source_file=$(pwd)/.tmux.conf
  local -r destination_file=$HOME/.tmux.conf

  # Check if destination config file already exists
  if [ -f "$destination_file" ]; then
    read -p "File $destination_file already exists. Do you want to remove it and install? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Installation cancelled."
      return 1
    fi
    rm -f "$destination_file"
  fi

  ln -s "$source_file" "$destination_file"
  echo "Install success, please press Ctrl+b+r in tmux mode to reload config"
}

# run install
install_config
