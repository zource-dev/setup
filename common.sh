#!/bash/sh

# At this point you should have already installed
# Git, VSCode, SublimeText, Dev Chromium, Docker, Postman, Figma
# MySQLWorkbench


# NODE
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
nvm install --lts
nvm use --lts
node --version
npm --version

# YARN
curl -o- -L https://yarnpkg.com/install.sh | bash
yarn --version