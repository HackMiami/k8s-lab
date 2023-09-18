
brew upgrade
brew install bash
echo $(brew --prefix)/bin/bash | sudo tee -a /private/etc/shells
sudo chpass -s $(brew --prefix)/bin/bash $USER
