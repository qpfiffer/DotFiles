# this script gets concatenated with base.sh

ensure_code deploy.erickson.is:quinlan/provisioner.git /app/eis

run_container 'postgres'