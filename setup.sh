#!/usr/bin/env bash

set -euo pipefail

instalar_pacotes=(
	calibre
	cowsay
	curl
	exiftool
	fastfetch
	ffmpeg
	fortune
	ghostwriter
	git
	imagemagick
	kcolorchooser
	kleopatra
	kolourpaint
	libreoffice-l10n-pt-br
	lolcat
	mkvtoolnix
	qbittorrent
	rsync
	texlive
	thunderbird
	vlc
	wget
)

remover_pacotes=(
	akregator
	dragonplayer
	juk
	kaddressbook
	kdeconnect
	kfind
	khelpcenter
	kmail
	kmag
	kmousetool
	kmouth
	konqueror
	kontrast
	korganizer
	plasma-welcome
	xterm
)

repositorios=(
	"https://github.com/martinhojoao/dotfiles.git|/home/joao/Área de trabalho/dotfiles"
	"https://github.com/martinhojoao/martinhojoao.github.io.git|/home/joao/Área de trabalho/Página pessoal"
)

backup_itens=(
	# Repositório
	"/home/joao/Área de trabalho/dotfiles/.bash_aliases|/home/joao/.bash_aliases|arquivo"
	"/home/joao/Área de trabalho/dotfiles/.gitconfig|/home/joao/.gitconfig|arquivo"
	"/home/joao/Área de trabalho/dotfiles/custom.cfg|/boot/grub/custom.cfg|arquivo"

	# Pendrive
	"/media/joao/Backup/Documentos|/home/joao/Documentos|conteudo"
	"/media/joao/Backup/Imagens|/home/joao/Imagens|conteudo"
	"/media/joao/Backup/Modelos|/home/joao/Modelos|conteudo"
	"/media/joao/Backup/Concurso|/home/joao/Área de trabalho|pasta"
	"/home/joao/Área de trabalho/dotfiles/.git-credentials|/home/joao/.git-credentials|arquivo"
	# "/media/joao/Backup/Saves|/home/joao/.config/StardewValley|pasta"
)

comandos_avulsos=(
	# "printf 'n\n\ny\n/home/joao/.sv\n1\n\n' | /media/joao/Backup/Jogos/sv.sh"
	# "printf 'n\n\ny\n/home/joao/.gf\n1\n\n' | /media/joao/Backup/Jogos/gf.sh"
	"sudo rm /home/joao/.face"
	"sudo rm /home/joao/.face.icon"
)

log() {
	printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}

checar_root() {
	if [[ $EUID -ne 0 ]]; then
		echo "Este script precisa ser executado como root."
		echo "Use: sudo $0"
		exit 1
	fi
}

instalar_pacotes_fn() {
	log "Atualizando lista de pacotes..."
	apt update

	log "Instalando pacotes..."
	apt install -y "${instalar_pacotes[@]}"
}

remover_pacotes_fn() {
	log "Removendo pacotes desnecessários..."
	apt purge -y "${remover_pacotes[@]}"

	log "Limpando dependências não utilizadas..."
	apt autoremove -y
}

clonar_repositorios() {
	log "Clonando repositórios..."

	for repo in "${repositorios[@]}"; do
		IFS="|" read -r url destino <<< "$repo"

		log "→ $url → $destino"

		if [[ -d "$destino/.git" ]]; then
			log "Atualizando repositório existente..."
			git -C "$destino" pull
		else
			git clone "$url" "$destino"
		fi
	done
}

restaurar_backup() {
	log "Restaurando backup..."

	for item in "${backup_itens[@]}"; do
		IFS="|" read -r origem destino modo <<< "$item"

		log "→ $origem → $destino ($modo)"

		if [[ ! -e "$origem" ]]; then
			log "Aviso: $origem não existe, pulando..."
			continue
		fi

		case "$modo" in
			conteudo)
				mkdir -p "$destino"
				rsync -a "$origem"/ "$destino"/
				;;
			pasta)
				rsync -a "$origem" "$destino"
				;;
			arquivo)
				mkdir -p "$(dirname "$destino")"
				rsync -a "$origem" "$destino"
				;;
			*)
				log "Modo desconhecido: $modo"
				;;
		esac
	done
}

customizar_grub() {
	local arquivo="/etc/default/grub"

	sed -i '/^#\?\s*GRUB_BACKGROUND=/d' "$arquivo"
	echo "GRUB_BACKGROUND=''" >> "$arquivo"

	sudo update-grub
}

configurar_sudo() {
	local user_file="/etc/sudoers.d/joao"
	local defaults_file="/etc/sudoers.d/00-custom"

	echo "joao ALL=(ALL:ALL) ALL" > "$user_file"
	chmod 440 "$user_file"

	touch "$defaults_file"

	grep -qE '^\s*Defaults\s+pwfeedback\b' "$defaults_file" || \
		echo "Defaults pwfeedback" >> "$defaults_file"

	grep -qE '^\s*Defaults\s+insults\b' "$defaults_file" || \
		echo "Defaults insults" >> "$defaults_file"

	chmod 440 "$defaults_file"
}

executar_comandos_avulsos() {
	log "Executando comandos avulsos..."

	for cmd in "${comandos_avulsos[@]}"; do
		log "→ $cmd"
		bash -c "$cmd"
	done
}

corrigir_permissoes_home() {
	log "Corrigindo permissões de /home/joao..."
	chown -R joao:joao /home/joao
}

main() {
	checar_root

	case "${1:-tudo}" in
		pacotes)
			instalar_pacotes_fn
			remover_pacotes_fn
			;;
		repos)
			clonar_repositorios
			corrigir_permissoes_home
			;;
		backup)
			restaurar_backup
			corrigir_permissoes_home
			;;
		configs)
			customizar_grub
			configurar_sudo
			;;
		tudo)
			instalar_pacotes_fn
			remover_pacotes_fn
			clonar_repositorios
			restaurar_backup
			customizar_grub
			configurar_sudo
			corrigir_permissoes_home
			;;
		*)
			echo "Uso: $0 [pacotes|repos|backup|configs|tudo]"
			exit 1
			;;
	esac

	log "Processo concluído."
}

main "$@"
