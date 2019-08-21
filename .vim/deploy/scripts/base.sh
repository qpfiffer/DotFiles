#!/bin/bash

set -o nounset
# set -e

export APP_DIR="/app"
DATOMIC_DIR="/datomic"
export APP_USER="ubuntu"
export APP_NAMESPACE="acuitas"
export DEPLOY_BRANCH="master"
GIT_SERVER_FINGERPRINT="github.com,192.30.252.131 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
JENKINS_HOME="/jenkins"

ensure_git() {
    if [[ ! $(which git) ]]; then
        echo "installing git"
        sudo apt-get install -y git
    fi
}

ensure_docker()
{
    if [[ ! $(which docker) ]]; then
        echo "installing docker"
        sudo sh -c "echo deb http://get.docker.io/ubuntu docker main\
        > /etc/apt/sources.list.d/docker.list"
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
        sudo apt-get -y update
        sudo apt-get install -y lxc-docker
    fi
    sudo gpasswd -a $APP_USER docker
}

remove_wrapping_quotes() {
    declare input
    declare output
    input=$1
    output="${input%\"}"
    output="${output#\"}"
    echo "$output"
}

get_cluster_detail() {
    local detailfile=$1
    local key=$2
    cat "$detailfile" | jq --compact-output ".$2"
}

export -f get_cluster_detail

cleaned_cluster_detail() {
    local detailfile=$1
    local key=$2
    local output=$(remove_wrapping_quotes "$(get_cluster_detail $detailfile $key)")
    echo $output
}

export -f cleaned_cluster_detail

read_details() {
    local detailfile=$1
    rds_id=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "rds_id"))
    region=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "region"))
    vpc_id=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "vpc_id"))
    sg_id=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "sg_id"))
    rds_endpoint=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "rds_endpoint[0]"))
    rds_port=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "rds_endpoint[1]"))
    subnet_ids=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "subnet_ids[]"))
    eid=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "elastic_allocation_id"))
    gateway_id=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "gateway_id"))
    instance_ip=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "instance_ip"))
    s3_bucket=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "s3_bucket"))
    instance_id=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "instance_id"))
    route_table_id=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "route_table_id"))
    cluster_label=$(remove_wrapping_quotes $(get_cluster_detail $detailfile "cluster_label"))
}

export -f read_details

ensure_app_user() {
    set +e
    sudo useradd -m -s /bin/bash $APP_USER
    sudo usermod -a -G sudo $APP_USER
    sudo -u $APP_USER mkdir -p "/home/${APP_USER}/.ssh"
    echo $GIT_SERVER_FINGERPRINT | sudo -u $APP_USER tee /home/$APP_USER/.ssh/known_hosts
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ubuntu
    sudo chmod 0440 /etc/sudoers.d/ubuntu
    set -e
}

ensure_app_dir() {
    sudo mkdir -p $APP_DIR
    sudo chown $APP_USER:$APP_USER $APP_DIR
}

get_code() {
    local REPOSITORY_URL=$1
    local CLONE_DIRECTORY=$2

    echo "cloning $REPOSITORY_URL into $CLONE_DIRECTORY"
    git clone git@"$REPOSITORY_URL" $CLONE_DIRECTORY
    chown -R $APP_USER:$APP_USER $CLONE_DIRECTORY
}

update_code() {
    local CLONE_DIRECTORY=$1

    echo "running git pull in $CLONE_DIRECTORY"

    pushd $CLONE_DIRECTORY
    set +e
    git checkout $DEPLOY_BRANCH
    if [[ $? != 0 ]]; then
        git checkout "master"
    fi
    set -e

    git pull
    popd

    echo "finished updating code"
}

ensure_code() {
    local REPOSITORY_URL=$1
    local CLONE_DIRECTORY=$2

    if [[ -d "$CLONE_DIRECTORY/.git" ]]; then
        update_code $CLONE_DIRECTORY
    else
        get_code $REPOSITORY_URL $CLONE_DIRECTORY
    fi
}

namespaced_name() {
    local TARGET_IMAGE_NAME=$1
    echo "$APP_NAMESPACE-$TARGET_IMAGE_NAME"
}

export -f namespaced_name

build_image() {
    local TARGET_IMAGE_NAME=$1
    local DEPLOY_DIR="$APP_DIR/deploy/$TARGET_IMAGE_NAME"
    local NAMESPACED_NAME=$(namespaced_name $TARGET_IMAGE_NAME)

    echo "Building image $NAMESPACED_NAME in $DEPLOY_DIR"
    pushd $DEPLOY_DIR
    docker build -t $NAMESPACED_NAME .
    popd
}

export -f build_image

run_app_container() {
    echo "run_app_container"
    local NAMESPACED_APP=$(namespaced_name app)
    local JAR=$1
    local dbhost=$2
    local dbport=$3
    local dbuser=$4
    local dbpass=$5
    local datomic_uri="datomic:sql://acuitas?jdbc:postgresql://$dbhost:$dbport/datomic?user=$dbuser&password=$dbpass"

    local RUNNING_CONTAINERS=$(docker ps -a | grep $NAMESPACED_APP | awk '{print $1}')
    if [[ $RUNNING_CONTAINERS ]]; then
        echo "killing"
        docker kill $RUNNING_CONTAINERS
        docker rm $RUNNING_CONTAINERS
    fi

    docker run -d \
        --name $NAMESPACED_APP \
        -e HTTP_PORT=80 \
        -e DB_URI="$datomic_uri" \
        -p 0.0.0.0:80:80 -v $APP_DIR:/app \
        $NAMESPACED_APP "$JAR"
}

export -f run_app_container

docker_run() {
    local TARGET_IMAGE_NAME=$1
    echo "running 'docker run $TARGET_IMAGE_NAME'"
    set -x
    eval "docker_run_$TARGET_IMAGE_NAME ${*:2}"
    set +x
}

export -f docker_run

run_container() {
    local TARGET_IMAGE_NAME=$1
    local NAMESPACED_NAME=$(namespaced_name $1)
    build_image $TARGET_IMAGE_NAME

    local RUNNING_CONTAINERS=$(docker ps -a | grep $NAMESPACED_NAME | awk '{print $1}')
    if [[ $RUNNING_CONTAINERS ]]; then

        docker kill $RUNNING_CONTAINERS
        docker rm $RUNNING_CONTAINERS
    fi

    docker_run $TARGET_IMAGE_NAME ${*:2}
}

export -f run_container

install_datomic_peer_lib() {
    echo "installing datomic"
    sudo apt-get install --assume-yes --force-yes openjdk-7-jre-headless maven
    curl http://files.survantjames.com.s3.amazonaws.com/datomic-pro-0.9.4572.zip > datomic-pro-0.9.4572.zip
    unzip datomic-pro-0.9.4572.zip
    sudo cp -r datomic-pro-0.9.4572/ $DATOMIC_DIR
    sudo chown -R ubuntu:ubuntu $DATOMIC_DIR
    pushd $DATOMIC_DIR; bin/maven-install; popd
}

install_datomic() {
    local host=$1
    local port=$2
    local user=$3
    local pass=$4
    sudo apt-get install unzip

    # first do the maven dance
    if [ ! -d $DATOMIC_DIR ]; then
        install_datomic_peer_lib
    else
        echo "datomic directory already in place, assuming datomic install completed"
    fi

    # then wire it into System V
    if [  /etc/init.d/datomic -ot $APP_DIR/deploy/config/datomic ] || \
       [ ! -f /etc/init.d/datomic ]; then
        echo "hooking datomic into System V"

        if [ -f /etc/init.d/datomic ]; then
            sudo rm /etc/init.d/datomic
        fi
        sudo cp $APP_DIR/deploy/config/datomic /etc/init.d/datomic
        sudo chmod 0755 /etc/init.d/datomic

        cp $APP_DIR/deploy/config/transactor.template $DATOMIC_DIR/transactor.properties

        sudo mkdir -p /var/log/datomic/
        sudo chown -R ubuntu:ubuntu /var/log/datomic/
    else
        echo "init script in place, assuming System V working as expected"
    fi

    echo "updating transactor.properties"
    cp $APP_DIR/deploy/config/transactor.template $DATOMIC_DIR/transactor.properties
    INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
    { echo "protocol=sql"; \
      echo "port=$port"; \
      echo "sql-url=jdbc:postgresql://$host:$port/datomic"; \
      echo "sql-user=$user"; \
      echo "sql-password=$pass"; \
      echo "host=$INSTANCE_IP"; } >> $DATOMIC_DIR/transactor.properties
}

export -f install_datomic

provision_rds() {
    echo "provisioning rds"
    local host=$1
    local port=$2
    local user=$3
    local pass=$4
    sudo apt-get install -y postgresql postgresql-contrib
    pushd $APP_DIR/deploy/scripts/
    env \
        PGHOST="$host" \
        PGPORT="$port" \
        PGPASSWORD="$pass" \
        PGUSER="$user" \
        psql -f datomic.sql
    popd
}

export -f provision_rds

start_datomic() {
    sudo service datomic start
}

restart_datomic() {
    sudo service datomic restart
}

backup_datomic_to_disk() {
    set -x
    local backup_dir=/tmp/$DATE.datomic/
    mkdir -p "$backup_dir"
    cd $DATOMIC_DIR; bin/datomic backup-db "$DATOMIC_URI" "file:$backup_dir"
    cd $backup_dir
    tar -zcf "../$DATE.datomic.tar.gz" .
    set +x
}

install_jenkins() {
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y openjdk-7-jre-headless openjdk-7-jdk git curl
    sudo chown ubuntu /opt
    curl -L http://mirrors.jenkins-ci.org/war/1.592/jenkins.war > /opt/jenkins.war
    sudo chmod 0644 /opt/jenkins.war
    sudo mkdir -p "$JENKINS_HOME"
}

run_ci() {
    set +e
    echo "killing docker"
    sudo killall docker
    echo "killing java"
    sudo killall java
    set -e
    echo "starting docker"
    docker -d &

    echo "starting jenkins"
    sudo java -DJENKINS_HOME="$JENKINS_HOME" -jar /opt/jenkins.war &
    echo "started jenkins with PID $!"
}

install_leiningen() {
    curl -L https://raw.github.com/technomancy/leiningen/stable/bin/lein | sudo tee /bin/lein
    sudo chmod a+x /bin/lein
    lein
}

test_command() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1"
    elif [ $status -eq 0 ]; then
        echo "test $1 completed successfully"
    fi
    return $status
}

export -f test_command

check_container_running() {
    local TARGET_IMAGE_NAME=$1
    docker ps | grep $TARGET_IMAGE_NAME > /dev/null
    return $?
}

export -f check_container_running

check_image_built_successfully() {
    local TARGET_IMAGE_NAME=$1
    docker images | grep $TARGET_IMAGE_NAME > /dev/null
    return $?
}

export -f check_image_built_successfully
