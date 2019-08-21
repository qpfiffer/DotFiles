#!/bin/bash
# this file to be concatenated with base.sh

ensure_git
ensure_app_dir
ensure_app_user
ensure_code github.com:survantjames/acuitas.git /app
install_datomic_peer_lib
install_leiningen
install_jenkins
run_ci
