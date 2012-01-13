#!/bin/bash
cd $(dirname $0)
echo -n "Updating git modules "
git submodule init                         >/dev/null 2>&1 && echo -n ". "
git submodule update                       >/dev/null 2>&1 && echo -n ". "
git submodule foreach git submodule init   >/dev/null 2>&1 && echo -n ". "
git submodule foreach git submodule update >/dev/null 2>&1 && echo -n ". "
echo "done"

for f in *; do
    [[ "${f}" = "${0}" ]] && continue
    [[ "${f:0:6}" = "README" ]] && continue
    link=${HOME}/.${f}
    this=${PWD}/${f}

    if [[ -e "${link}" ]]; then
        if [[ -L "${link}" ]]; then
            end=$(python -c "import os; print os.path.realpath('${link}');")

            if [[ "${end}" != "${this}" ]]; then
                echo "[FAIL] ${link} points elsewhere. Fix it yourself." >&2
            fi
        else
            echo "[FAIL] .${f} exists in \$HOME. Symlink it yourself." >&2
        fi
    else
        ln -s "${this}" "${link}"
        echo "[ OK ] Created $link" >&2
    fi
done
