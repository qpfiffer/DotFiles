# this script gets concatenated with base.sh

RDS_HOST=$1
RDS_PORT=$2
RDS_USER=$3
RDS_PASS=$4

ensure_git
ensure_docker
ensure_app_dir
ensure_app_user
ensure_code github.com:survantjames/acuitas.git /app
build_image app
install_datomic "$RDS_HOST" "$RDS_PORT" "$RDS_USER" "$RDS_PASS"
provision_rds "$RDS_HOST" "$RDS_PORT" "$RDS_USER" "$RDS_PASS"
start_datomic
