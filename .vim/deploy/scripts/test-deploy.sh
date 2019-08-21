
check_redis_running() {
    check_container_running "redis"
    return $?
}

check_eis_running() {
    check_container_running "eis"
    return $?
}

check_webhook_running() {
    check_container_running "docs-webhook"
    return $?
}

check_static_running() {
    check_container_running "docs-static"
    return $?
}

check_redis_built_successfully() {
    check_image_built_successfully "redis"
    return $?
}

check_eis_built_successfully() {
    check_image_built_successfully "eis"
    return $?
}

test_command check_redis_built_successfully
test_command check_eis_built_successfully

test_command check_redis_running
test_command check_eis_running
test_command check_webhook_running
test_command check_static_running
