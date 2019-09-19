#!/bin/bash

## This can be reused elsewhere in order to determine latest component version based on the map in `versions` file. 
function get_component_version_by_plat_version() {
    curl -s https://raw.githubusercontent.com/contiamo/platform-version/master/versions | grep $(curl -s https://api.github.com/repos/contiamo/platform-version/releases/latest | jq .tag_name -r) > /dev/null
    result=$?
    while [[ $result == "1" ]]; do 
      curl -s https://raw.githubusercontent.com/contiamo/platform-version/master/versions | grep $(curl -s https://api.github.com/repos/contiamo/platform-version/releases/latest | jq .tag_name -r) > /dev/null
      result=$?
      sleep 1; 
    done
    curl -s https://raw.githubusercontent.com/contiamo/platform-version/master/versions | grep $(curl -s https://api.github.com/repos/contiamo/platform-version/releases/latest | jq .tag_name -r)

}

## This commented out function can be reused elsewhere to determine the latest platform version.
# function get_latest_plat_version() {
#     curl -s https://api.github.com/repos/contiamo/platform-version/releases/latest | jq .tag_name -r
# }

function get_component_latest_release() {
    APP=$1
    curl -H 'Cache-Control: no-cache' -s https://www.googleapis.com/storage/v1/b/contiamo-kv/o/${APP}/?alt=media
}

function get_components {
    gsutil ls gs://contiamo-kv | awk -F '/' '{print $4}'
}


function populate_version_map() {
    PLAT_VERSION=$1
    for COMPONENT in $(get_components); do
        echo "${PLAT_VERSION} ${COMPONENT} $(get_component_latest_release ${COMPONENT})"
    done
}

if [[ $1 == "map" ]]; then 
    #The TAG_NAME env. var is provided by Jenkins.
    populate_version_map ${TAG_NAME} >> versions
fi

if [[ $1 == "get" ]]; then
    get_component_version_by_plat_version
fi