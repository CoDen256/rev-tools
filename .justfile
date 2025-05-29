import "~/.justfile"

dis PACKAGE NAME:
    @echo "Disassembling '{{PACKAGE}}' to '{{NAME}}'"
    at -v pull {{PACKAGE}} -n {{NAME}} -d {{NAME}} -m
    at -v dis -f {{NAME}}/*{{NAME}}.apk
    ln -fs ../.justfile {{NAME}}/.justfile
    ls {{NAME}}


ass REPO NAME:
    @echo "Assembling '{{REPO}}'"
    at -v bl -azscf {{REPO}}
    at -v in -f {{NAME}}/signed.*

prep REPO:
    @echo "Preparing a git repo in {{REPO}}"
    cp ~/rev/tools/.gitignore.example {{REPO}}/.gitignore
    ls -la {{REPO}}
    git init {{REPO}}

    git -C {{REPO}} config core.autocrlf false
    git -C {{REPO}} config feature.manyFiles true
    git -C {{REPO}} add . &> /dev/null
    git -C {{REPO}} commit -m "init" &> /dev/null
    code {{REPO}} &
    android-studio {{REPO}} &

init:
    ln -s $PWD/.justfile ../.justfile