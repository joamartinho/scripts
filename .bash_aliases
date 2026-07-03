# Variáveis Globais
export DIR_DOTFILES="/home/joao/Área de trabalho/Dotfiles"

# APT
alias atualizar='sudo apt update && sudo apt full-upgrade -y'
alias buscar='apt search'
alias instalar='sudo apt install -y'
alias listar='apt list --installed | grep '
alias remover='sudo apt purge -y'
alias limpar='sudo apt autoclean && sudo apt autoremove --purge -y'

# Git
alias add='git add .'
alias cap='git add . && git commit -m "$(date +%F)" && git push'
alias clonar='git clone'
alias commit='git commit -m "$(date +%F)"'
alias desfazer='git stash && git pull'
alias fetch='git fetch'
alias merge='git merge --no-edit'
alias publicar='git add . && git commit -m "$(date +%F)" && git switch --create main && git push --set-upstream origin main'
alias pull='git pull'
alias push='git push'
alias restaurar='git reset --hard'
alias revincular='git remote set-url origin'
alias vincular='git init && git remote add origin'
alias voltar='git reset --hard HEAD^'

# Scripts
alias ajustar='bash "$DIR_DOTFILES/ajustar.sh"'
alias backup='bash "$DIR_DOTFILES/backup.sh"'
alias contar='bash "$DIR_DOTFILES/contar.sh"'
alias extrair='bash "$DIR_DOTFILES/extrair.sh"'
alias formatar='bash "$DIR_DOTFILES/formatar.sh"'
alias fps='bash "$DIR_DOTFILES/fps.sh"'
alias transferir='bash "$DIR_DOTFILES/transferir.sh"'
alias normalizar='bash "$DIR_DOTFILES/normalizar.sh"'
alias remover='bash "$DIR_DOTFILES/remover.sh"'

# Outros
alias cat='lolcat'
alias editar='sudo nano'
alias fortune='fortune fortunes riddles | cowsay'
alias free='free -h'
alias python='python3'
