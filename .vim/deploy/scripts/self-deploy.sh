# this script gets concatenated with base.sh

# update code
ensure_code github.com:survantjames/acuitas.git /app

# restart app container with the new ref
run_app_container "$@"
