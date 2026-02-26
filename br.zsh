br() {
    local sel=0 act=0 msg="" items types entry idx icon key a

    local folder_actions=("open" "copy path" "reveal in finder")
    local file_actions=("copy path" "open in editor" "reveal in finder")

    printf '\e[?1049h\e[?25l'

    while true; do
        items=(); types=()
        items+=('..'); types+=('folder')

        while IFS= read -r entry; do
            [[ -n "$entry" ]] && items+=("$entry") && types+=('folder')
        done < <(ls -1p 2>/dev/null | grep '/$')

        while IFS= read -r entry; do
            [[ -n "$entry" ]] && items+=("$entry") && types+=('file')
        done < <(ls -1p 2>/dev/null | grep -v '/$')

        (( sel >= ${#items[@]} )) && sel=$(( ${#items[@]} - 1 ))
        (( sel < 0 )) && sel=0

        local cur_type="${types[$((sel + 1))]}"
        local -a cur_actions
        if [[ $cur_type == "folder" ]]; then
            cur_actions=("${folder_actions[@]}")
        else
            cur_actions=("${file_actions[@]}")
        fi
        (( act >= ${#cur_actions[@]} )) && act=0

        local buf=$'\e[H\e[1;34m  '"$(pwd)"$'\e[0m\e[K\n\e[K\n'

        for idx in {1..${#items[@]}}; do
            [[ "${types[$idx]}" == "folder" ]] && icon="+" || icon=" "

            if (( idx == sel + 1 )); then
                buf+=$'  \e[30;47m '"$icon"' '"${items[$idx]}"$' \e[0m\e[K\n'
            elif [[ "${types[$idx]}" == "file" ]]; then
                buf+=$'  \e[2m  '"${items[$idx]}"$'\e[0m\e[K\n'
            else
                buf+=$'    '"${items[$idx]}"$'\e[K\n'
            fi
        done

        buf+=$'\e[K\n  '
        for a in {1..${#cur_actions[@]}}; do
            if (( a - 1 == act )); then
                buf+=$'\e[1;7m '"${cur_actions[$a]}"$' \e[0m '
            else
                buf+=$'\e[2m'"${cur_actions[$a]}"$'\e[0m '
            fi
        done
        buf+=$'\e[K\n'

        if [[ -n "$msg" ]]; then
            buf+=$'\e[K\n  \e[32m'"$msg"$'\e[0m\e[K\n'
            msg=""
        else
            buf+=$'\e[K\n\e[K\n'
        fi

        buf+=$'  \e[2m↑↓ navigate · tab action · enter execute · esc quit\e[0m\e[K\e[J'
        printf '%s' "$buf"

        read -rsk1 key
        case $key in
            $'\e')
                read -rsk1 -t 0.1 key
                if [[ $key == '[' ]]; then
                    read -rsk1 -t 0.1 key
                    [[ $key == 'A' ]] && (( sel-- )) && act=0
                    [[ $key == 'B' ]] && (( sel++ )) && act=0
                else
                    break
                fi
                ;;
            $'\t')
                (( act = (act + 1) % ${#cur_actions[@]} ))
                ;;
            $'\n')
                local target="${items[$((sel + 1))]}"
                local action="${cur_actions[$((act + 1))]}"
                local full_path="$(pwd)/${target%/}"

                case $action in
                    "open")
                        builtin cd "${target%/}" 2>/dev/null && sel=0 && act=0
                        ;;
                    "copy path")
                        printf '%s' "$full_path" | pbcopy
                        msg="copied: $full_path"
                        ;;
                    "open in editor")
                        printf '\e[?1049l\e[?25h'
                        ${EDITOR:-open} "$target"
                        printf '\e[?1049h\e[?25l'
                        ;;
                    "reveal in finder")
                        open -R "$full_path"
                        msg="revealed in Finder"
                        ;;
                esac
                ;;
        esac
    done

    printf '\e[?1049l\e[?25h'
    ls
}
