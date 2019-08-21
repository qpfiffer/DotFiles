
check_docker() {
    docker ps >> /dev/null
    return $?
}

test_command check_docker
