#!/bin/bash -e

HOST=$1

ssh -At "$HOST" docker exec -it eis-postgres psql postgresql://eis:password@localhost/eis