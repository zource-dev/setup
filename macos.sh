#!/bin/sh

smart-brew() {
  [[ $(brew ls --versions $1 >/dev/null) ]] && OP="upgrade" || OP="install"
  $("brew $2 $OP $1")
}

smart-brew git
smart-brew docker cask
smart-brew visual-studio-code cask
smart-brew sublime-text cask
smart-brew postman cask
smart-brew figma cask
smart-brew mysqlworkbench cask

curl -o- https://zource.dev/setup/common.sh | bash