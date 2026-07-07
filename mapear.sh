#!/bin/bash

PREFIXO="$1"
REVERTER="$2"

if [ -z "$PREFIXO" ]; then
    echo "Erro: Prefixo não informado."
    exit 1
fi

shopt -s globstar

if [ "$REVERTER" == "--reverter" ]; then
    for arquivo in **/*; do
        [ -f "$arquivo" ] || continue
        diretorio=$(dirname "$arquivo")
        nome_arquivo=$(basename "$arquivo")

        if [[ "$diretorio" =~ Temporada\ ([0-9]+)$ ]]; then
            num_temporada="${BASH_REMATCH[1]}"
        else
            echo "Aviso: Direitório fora do padrão ignorado -> $diretorio"
            continue
        fi

        padrao="^${PREFIXO} S${num_temporada}E([0-9]+) (.*)$"
        if [[ "$nome_arquivo" =~ $padrao ]]; then
            num_episodio="${BASH_REMATCH[1]}"
            resto_nome="${BASH_REMATCH[2]}"
            novo_nome="${num_episodio}. ${resto_nome}"
            mv "$arquivo" "$diretorio/$novo_nome"
        else
            if [[ ! "$nome_arquivo" =~ ^[0-9]+\.\  ]]; then
                echo "Aviso: Arquivo fora do padrão ignorado -> $arquivo"
            fi
        fi
    done
else
    for arquivo in **/*; do
        [ -f "$arquivo" ] || continue
        diretorio=$(dirname "$arquivo")
        nome_arquivo=$(basename "$arquivo")

        if [[ "$diretorio" =~ Temporada\ ([0-9]+)$ ]]; then
            num_temporada="${BASH_REMATCH[1]}"
        else
            echo "Aviso: Direitório fora do padrão ignorado -> $diretorio"
            continue
        fi

        if [[ "$nome_arquivo" =~ ^([0-9]+)\.\ (.*)$ ]]; then
            num_episodio="${BASH_REMATCH[1]}"
            resto_nome="${BASH_REMATCH[2]}"
            novo_nome="${PREFIXO} S${num_temporada}E${num_episodio} ${resto_nome}"
            mv "$arquivo" "$diretorio/$novo_nome"
        else
            if [[ ! "$nome_arquivo" =~ ^${PREFIXO}\ S[0-9]+E[0-9]+ ]]; then
                echo "Aviso: Arquivo fora do padrão ignorado -> $arquivo"
            fi
        fi
    done
fi
