find . -type f \( -iname '*.mkv' -o -iname '*.mp4' \) -print0 |
while IFS= read -r -d $'\0' f; do
    echo "Processando: $f"

    case "${f,,}" in
        *.mkv)
        tmp="${f%.mkv}.tmp.mkv"

        first_audio_id=$(mkvmerge -J "$f" | jq -r '.tracks[] | select(.type=="audio") | .id' | head -n 1)

        cmd=(mkvmerge -o "$tmp" \
            --title "" \
            --no-chapters \
            --no-track-tags \
            --no-global-tags \
            --no-attachments \
            --no-subtitles)

        [ -n "$first_audio_id" ] && cmd+=(--audio-tracks "$first_audio_id")

        for i in 0 1 2 3; do
            cmd+=(--track-name "$i:")
        done

        [ -n "$first_audio_id" ] && cmd+=(--language "$first_audio_id:und")

        cmd+=("$f")

        if "${cmd[@]}"; then
            mv -f "$tmp" "$f"
        else
            echo "Erro (MKV): $f"
            rm -f "$tmp"
        fi
        ;;

        *.mp4)
        tmp="${f%.mp4}.tmp.mp4"

        ffmpeg -nostdin -v error -y \
            -ignore_chapters 1 \
            -i "$f" \
            -map 0:v:0 \
            -map 0:a:0? \
            -sn \
            -map -0:d \
            -c copy \
            -disposition:v:0 0 \
            -map_metadata -1 \
            -map_chapters -1 \
            -metadata title= \
            -metadata:s:a:0 language=und \
            "$tmp"

        if [ $? -eq 0 ]; then
            mv -f "$tmp" "$f"
        else
            echo "Erro (MP4): $f"
            rm -f "$tmp"
        fi
        ;;
    esac
done
