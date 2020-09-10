upgrade_velocity(){
  echo "Upgrading velocity and cleaning up docker.."
  docker-compose stop web webpacker;
  docker-compose rm -f web webpacker;
  docker container prune --force --filter until=168h; # One week
  docker image prune --force;
  docker-compose build web webpacker;
  docker-compose up -d web webpacker;
  make db.migrate
}


prettier(){
  FILES=$(git diff master --name-only --diff-filter=ACM "*.js" "*.jsx" "*.tsx" "*.ts" "*.scss")
  echo "$FILES" | xargs yarn run --silent prettier --write --loglevel error
}
