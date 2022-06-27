alias dc="docker-compose"

alias dcr="docker-compose run --rm"

alias kubectl="minikube kubectl --"
alias k="kubectl"

docker__clean() {
    echo "Stopping containers.."
    [[ ! -z $(docker ps -a -q) ]] && docker stop $(docker ps -a -q)

    echo "Removing containers.."
    [[ ! -z $(docker ps --all -q -f status=exited) ]] && docker rm $(docker ps --all -q -f status=exited)

    echo "Removing images.."
    for image in "$@"
    do
        echo "Removing image \"$image\""
        [[ ! -z $(docker images -q "$image") ]] && docker rmi -f "$image"
    done

    echo "Removing dangling images.."
    [[ ! -z $(docker images -f "dangling=true" -q) ]] && docker rmi -f $(docker images -f "dangling=true" -q)
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
