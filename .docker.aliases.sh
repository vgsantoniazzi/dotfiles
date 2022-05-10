alias dc="docker-compose"

alias dcr="docker-compose run --rm"

alias k="kubectl"

docker__clean() {
    echo "Stopping containers.."
    result=$(docker ps -a -q)
    [[ ! -z "$result" ]] && docker stop "$result"

    echo "Removing containers.."
    result=$(docker ps --all -q -f status=exited)
    [[ ! -z "$result" ]] && docker rm result

    echo "Removing images.."
    for image in "$@"
    do
        echo "Removing image \"$image\""
        [[ ! -z $(docker images -q "$image") ]] && docker rmi -f "$image"
    done

    echo "Removing dangling images.."
    result=$(docker images -f "dangling=true" -q)
    [[ ! -z "$result" ]] && docker rmi -f result
    echo "Done!"
}

docker() {
  local cmdname=$1; shift
  if type "docker__$cmdname" >/dev/null 2>&1; then
    "docker__$cmdname" "$@"
  else
    command docker "$cmdname" "$@" # call the **real** docker command
  fi
}
