alias dc="docker-compose"

alias dcr="docker-compose run --rm"

docker_clean(){
  docker rm $(docker ps --all -q -f status=exited)
}

docker_stop() {
  docker stop $(docker ps -a -q)
}
