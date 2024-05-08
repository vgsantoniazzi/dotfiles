alias fix='sudo chown vgsantoniazzi:vgsantoniazzi '

prettier(){
  FILES=$(git diff master --name-only --diff-filter=ACM "*.js" "*.jsx" "*.tsx" "*.ts" "*.scss")
  echo "$FILES" | xargs yarn run --silent prettier --write --loglevel error
}
