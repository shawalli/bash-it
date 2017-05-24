cite about-plugin
about-plugin 'git alias initializer'

read -r -d '' ALIAS_CONTENTS <<- EOF
[alias]
  # analogous to svn up
  up = pull
  # diff a commit
  cdiff = “!f() { git diff “$1”^ “$1”; }; f”
  # list files from a commit
  ls = log --stat --name-only
EOF

git() {
    if [[ $# -ge 1 ]]; then
        if [[ ${@:1:1} == "alias" ]]; then
            GIT_CONFIG_DIR=`git rev-parse --show-toplevel`/.git
            CONFIG=${GIT_CONFIG_DIR}/config
            ALIAS=${GIT_CONFIG_DIR}/alias
            if [[ $# -eq 1 ]]; then
                ALIAS_COMMAND="list"
            else
                ALIAS_COMMAND="${@:2:1}"
            fi

            case ${ALIAS_COMMAND} in
            list)
                if [[ -f ${ALIAS} ]]; then
                    echo "  Alias     Description"
                    DESCRIPTION=
                    while read LINE; do
                        if [[ "x$LINE" == "x" ]] || [[ "${LINE}" == "[alias]" ]]; then
                            DESCRIPTION=
                        elif [[ "${LINE:0:1}" == '#' ]]; then
                            DESCRIPTION=${LINE:1}
                        else
                            echo "  ${LINE%%=*}"
                            if [[ "x${DESCRIPTION}" != "x" ]]; then
                                echo "           ${DESCRIPTION}"
                                DESCRIPTION=
                            else
                                echo
                            fi
                        fi
                    done < ${ALIAS}
                else
                    echo "No aliases found."
                fi
                ;;
            init)
                cat << EOF >> "${CONFIG}"
[include]
	path=alias
EOF
                echo "${ALIAS_CONTENTS}" > "${ALIAS}"
                echo "Alias initialization complete."
                ;;
            *)
                echo "Invalid alias command"
                ;;
         esac
         return
        fi
    fi
    command git $@
}
