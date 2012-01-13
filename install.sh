#!/bin/bash
cd $(dirname $0)
echo -n "Initializing git modules "
git submodule init    >/dev/null 2>&1 && echo -n ". "
git submodule update  >/dev/null 2>&1 && echo -n ". "
echo "done"

for f in *; do
    [[ "${f}" = "${0}" ]] && continue
    [[ "${f:0:6}" = "README" ]] && continue
    link=${HOME}/.${f}
    this=${PWD}/${f}

    if [[ -L "${link}" ]]; then
	end=$(python -c "import os; print os.path.realpath('${link}');")

	if [[ "${end}" != "${this}" ]]; then
	    echo "[FAIL] ${link} points elsewhere. Fix it yourself." >&2
	fi
    else
	if [[ -f "${link}" -o -d "${link}" ]]; then
	    echo "[FAIL] .${f} exists in \$HOME. Symlink it yourself." >&2
	else
	    ln -s "${this}" "${link}"
	    echo "[ OK ] Created $link" >&2
	fi
    fi
done
