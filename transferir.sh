#!/bin/bash

LOCAL_DIR="/home/joao/Vídeos"
BASE_USB_DIR="/media/joao/Videoteca"

if [ "$1" != "push" ] && [ "$1" != "pull" ]; then
	echo "Uso: $0 [push|pull] [series|filmes|animacoes]"
	exit 1
fi

if [ "$2" != "series" ] && [ "$2" != "filmes" ] && [ "$2" != "animacoes" ]; then
	echo "Erro: segundo argumento deve ser 'series', 'filmes' ou 'animacoes'."
	exit 1
fi

if [ "$2" = "series" ]; then
	USB_DIR="$BASE_USB_DIR/_Séries"
elif [ "$2" = "filmes" ]; then
	USB_DIR="$BASE_USB_DIR/_Filmes"
else
	USB_DIR="$BASE_USB_DIR/_Animações"
fi

if [ ! -d "$LOCAL_DIR" ]; then
	echo "Erro: Diretório local não existe."
	exit 1
fi

if [ ! -d "$USB_DIR" ]; then
	echo "Erro: Diretório do HD externo não existe."
	exit 1
fi

echo "----------------------------------------"

if [ "$1" = "push" ]; then
	echo "Enviando arquivos do LOCAL para o HD EXTERNO..."
	SRC="$LOCAL_DIR"
	DEST="$USB_DIR"
else
	echo "Trazendo arquivos do HD EXTERNO para o LOCAL..."
	SRC="$USB_DIR"
	DEST="$LOCAL_DIR"
fi

echo "Origem: $SRC"
echo "Destino: $DEST"
echo "----------------------------------------"

rsync -av --no-progress "$SRC"/ "$DEST"/

STATUS=$?

echo "----------------------------------------"

if [ $STATUS -eq 0 ]; then
	echo "Transferência concluída com sucesso."
else
	echo "Ocorreu um erro durante a transferência."
fi

echo "----------------------------------------"
