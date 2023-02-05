#!/bin/bash -

export JSONNET_PATH=${JSONNET_PATH:-/go/vendor}

export DASHBOARDS_JSONNET_PATH=${DASHBOARDS_JSONNET_PATH:-/src/dashboards_jsonnet}
export DASHBOARDS_JSON_PATH=${DASHBOARDS_JSON_PATH:-/src/dashboards_json}

export TERRAFORM_PLUGIN_PATH=${TERRAFORM_PLUGIN_PATH:-/src/terraform}
export TERRAFORM_RUN_PATH=${TERRAFORM_RUN_PATH:-/tmp}

render() {
    echo executing: render function \(jsonnet\)
    cd ${DASHBOARDS_JSONNET_PATH}

    if test "${1}"
    then
        FILES="${1}"
    else
        FILES=$(find . -type f -name '*jsonnet')
    fi

    for file in ${FILES}
    do
        echo rendering: $file
        jsonnet -J ${JSONNET_PATH} -o ${DASHBOARDS_JSON_PATH}/${file%.*}.json ${file}
    done
}

tf-init() {
    echo executin: terraform init
    cd ${TERRAFORM_RUN_PATH}

    terraform init -plugin-dir ${TERRAFORM_PLUGIN_PATH}
}

tf-apply() {
    echo executin: terraform apply
    cd ${TERRAFORM_RUN_PATH}

    terraform apply -auto-approve
}

export -f render
export -f tf-init
export -f tf-apply

main() {
    case ${1} in
        watch)
            render && tf-init && tf-apply
            cd ${DASHBOARDS_JSONNET_PATH}
            reflex -r "\.jsonnet$" -- bash -c 'render {} && tf-init && tf-apply'
        ;;

        render)
            render && tf-init && tf-apply
        ;;

        *)
            echo command not supported
            echo supported commands: watch, render
        ;;
    esac
}

main "$@"
