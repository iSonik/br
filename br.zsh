br() {
    local sel=0 act=0 msg="" scroll=0 filter="" items types entry idx icon key a

    local folder_actions=("open" "copy path" "reveal in finder")
    local file_actions=("copy path" "open in editor" "reveal in finder")

    printf '\e[?1049h\e[?25l'

    while true; do
        local -a all_items all_types
        all_items=(); all_types=()
        all_items+=('..'); all_types+=('folder')

        while IFS= read -r entry; do
            [[ -n "$entry" ]] && all_items+=("$entry") && all_types+=('folder')
        done < <(ls -1p 2>/dev/null | grep '/$')

        while IFS= read -r entry; do
            [[ -n "$entry" ]] && all_items+=("$entry") && all_types+=('file')
        done < <(ls -1p 2>/dev/null | grep -v '/$')

        items=(); types=()
        if [[ -z "$filter" ]]; then
            items=("${all_items[@]}")
            types=("${all_types[@]}")
        else
            local lf="${filter:l}"
            for idx in {1..${#all_items[@]}}; do
                if [[ "${all_items[$idx]:l}" == *"$lf"* ]]; then
                    items+=("${all_items[$idx]}")
                    types+=("${all_types[$idx]}")
                fi
            done
        fi

        local total=${#items[@]}
        if (( total > 0 )); then
            (( sel %= total ))
            (( sel < 0 )) && (( sel += total ))
        else
            sel=0
        fi

        local cur_type="${types[$((sel + 1))]}"
        local -a cur_actions
        if [[ $cur_type == "folder" ]]; then
            cur_actions=("${folder_actions[@]}")
        else
            cur_actions=("${file_actions[@]}")
        fi
        (( act >= ${#cur_actions[@]} )) && act=0

        local rows=$(tput lines)
        local visible=$(( rows - 7 ))
        (( visible < 1 )) && visible=1

        (( sel < scroll )) && scroll=$sel
        (( sel >= scroll + visible )) && scroll=$(( sel - visible + 1 ))
        (( scroll < 0 )) && scroll=0

        local end=$(( scroll + visible ))
        (( end > total )) && end=$total

        local buf=$'\e[H\e[1;34m  '"$(pwd)"$'\e[0m\e[K\n'

        if [[ -n "$filter" ]]; then
            buf+=$'  \e[33m/ '"$filter"$'\e[0m\e[K\n'
        else
            buf+=$'\e[K\n'
        fi

        if (( scroll > 0 )); then
            buf+=$'  \e[2m  ↑ '"$scroll"$' more\e[0m\e[K\n'
        else
            buf+=$'\e[K\n'
        fi

        if (( total == 0 )); then
            buf+=$'  \e[2m  no matches\e[0m\e[K\n'
        else
            for idx in {$((scroll + 1))..$end}; do
                [[ "${types[$idx]}" == "folder" ]] && icon="+" || icon=" "

                if (( idx == sel + 1 )); then
                    buf+=$'  \e[30;47m '"$icon"' '"${items[$idx]}"$' \e[0m\e[K\n'
                elif [[ "${types[$idx]}" == "file" ]]; then
                    buf+=$'  \e[2m  '"${items[$idx]}"$'\e[0m\e[K\n'
                else
                    buf+=$'    '"${items[$idx]}"$'\e[K\n'
                fi
            done
        fi

        local remaining=$(( total - end ))
        if (( remaining > 0 )); then
            buf+=$'  \e[2m  ↓ '"$remaining"$' more\e[0m\e[K\n'
        else
            buf+=$'\e[K\n'
        fi

        buf+=$'\e[K\n  '
        if (( total > 0 )); then
            for a in {1..${#cur_actions[@]}}; do
                if (( a - 1 == act )); then
                    buf+=$'\e[1;7m '"${cur_actions[$a]}"$' \e[0m '
                else
                    buf+=$'\e[2m'"${cur_actions[$a]}"$'\e[0m '
                fi
            done
        fi
        buf+=$'\e[K\n'

        if [[ -n "$msg" ]]; then
            buf+=$'\e[K\n  \e[32m'"$msg"$'\e[0m\e[K\n'
            msg=""
        else
            buf+=$'\e[K\n\e[K\n'
        fi

        buf+=$'  \e[2m↑↓ navigate · tab action · enter execute · type to search · esc quit\e[0m\e[K\e[J'
        printf '%s' "$buf"

        read -rsk1 key
        case $key in
            $'\e')
                read -rsk1 -t 0.1 key
                if [[ $key == '[' ]]; then
                    read -rsk1 -t 0.1 key
                    if [[ $key == 'A' ]]; then
                        if (( total > 0 )); then
                            (( sel-- ))
                            (( sel < 0 )) && (( sel = total - 1 ))
                            act=0
                        fi
                    elif [[ $key == 'B' ]]; then
                        if (( total > 0 )); then
                            (( sel++ ))
                            (( sel >= total )) && (( sel = 0 ))
                            act=0
                        fi
                    fi
                else
                    if [[ -n "$filter" ]]; then
                        filter=""
                        sel=0 && scroll=0 && act=0
                    else
                        break
                    fi
                fi
                ;;
            $'\t')
                (( total > 0 )) && (( act = (act + 1) % ${#cur_actions[@]} ))
                ;;
            $'\n')
                (( total == 0 )) && continue
                local target="${items[$((sel + 1))]}"
                local action="${cur_actions[$((act + 1))]}"
                local full_path="$(pwd)/${target%/}"

                case $action in
                    "open")
                        builtin cd "${target%/}" 2>/dev/null && sel=0 && act=0 && scroll=0 && filter=""
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
            $'\x7f'|$'\b')
                if [[ -n "$filter" ]]; then
                    filter="${filter%?}"
                    sel=0 && scroll=0 && act=0
                fi
                ;;
            [[:print:]])
                filter+="$key"
                sel=0 && scroll=0 && act=0
                ;;
        esac
    done

    printf '\e[?1049l\e[?25h'
    ls
}
