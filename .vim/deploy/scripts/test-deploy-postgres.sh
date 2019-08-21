
check_postgres_built_successfully() {
    check_image_built_successfully "postgres"
    return $?
}

check_postgres_running() {
    check_container_running "postgres"
    return $?
}

test_command check_postgres_built_successfully
test_command check_postgres_running
