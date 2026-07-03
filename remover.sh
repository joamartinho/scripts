#!/bin/bash

set -e
shopt -s nullglob

process_file () {
	local f="$1"

	if [[ ! -f "$f" ]]; then
		return
	fi

	local ext="${f##*.}"
	local base="${f%.*}"
	local tmp="${base}.tmp.${ext}"

	case "${f,,}" in
		*.mkv)
			echo "Removendo todas as legendas de (MKV): $f"
			mkvmerge -o "$tmp" --no-subtitles "$f"
			;;
		*.mp4)
			echo "Removendo todas as legendas de (MP4): $f"
			ffmpeg -i "$f" -map 0 -map -0:s -c copy "$tmp"
			;;
		*)
			echo "Ignorando (não é MKV/MP4): $f"
			return
			;;
	esac

	mv "$tmp" "$f"
	echo "Concluído: $f"
}

echo "Procurando todos os arquivos MKV e MP4 recursivamente..."

find . -type f \( -iname "*.mkv" -o -iname "*.mp4" \) -print0 | while IFS= read -r -d '' f; do
	process_file "$f"
done

echo "Todos os arquivos foram processados."
