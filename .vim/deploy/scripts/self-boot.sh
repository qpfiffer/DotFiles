
ensure_python_dependency_image

bootstrap_it /app/eis/it-documentation

run_container 'redis'

run_python_container

run_container 'nginx'
