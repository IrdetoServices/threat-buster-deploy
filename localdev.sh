#!/usr/bin/env bash

echo "Running local dynamo and local janus DB - press Control-C to exit"

export DYNAMOBD_JANUS_PROJECT='./dynamodb-janusgraph-storage-backend'

pushd $DYNAMOBD_JANUS_PROJECT
export ARTIFACT_NAME=`mvn -q -Dexec.executable="echo" -Dexec.args='${project.artifactId}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec`
export JANUSGRAPH_DYNAMODB_HOME=${PWD}
export JANUSGRAPH_DYNAMODB_TARGET=${JANUSGRAPH_DYNAMODB_HOME}/target
export JANUSGRAPH_VERSION=`mvn -q -Dexec.executable="echo" -Dexec.args='${janusgraph.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec`
export TINKERPOP_VERSION=`mvn -q -Dexec.executable="echo" -Dexec.args='${tinkerpop.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec`
export DYNAMODB_PLUGIN_VERSION=`mvn -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive org.codehaus.mojo:exec-maven-plugin:1.3.1:exec`
export JANUSGRAPH_DYNAMODB_SERVER_DIRNAME=${ARTIFACT_NAME}-${DYNAMODB_PLUGIN_VERSION}
export WORKDIR=${JANUSGRAPH_DYNAMODB_HOME}/server
export JANUSGRAPH_SERVER_HOME=${WORKDIR}/${JANUSGRAPH_DYNAMODB_SERVER_DIRNAME}

while getopts c OPTION
do	case "$OPTION" in
	c)	CLEAN=true;
	    echo "Cleaning"
	    rm -rf $WORKDIR
	    ;;
	[?])	print >&2 "Usage: $0 [-c]"
		exit 1;;
	esac
done

if [ ! -d "server" ]; then
    echo "Building Docker Images using shipped build scripts - make a coffee!"
    src/test/resources/install-gremlin-server.sh
    ./bin/gremlin-server.sh -i org.apache.tinkerpop gremlin-python $TINKERPOP_VERSION
    pushd $DYNAMOBD_JANUS_PROJECT
    cp $WORKDIR/dynamodb-janusgraph-storage-backend-*.zip src/test/resources/dynamodb-janusgraph-docker
    mvn docker:build -Pdynamodb-janusgraph-docker

fi

if ! pgrep -f docker > /dev/null ; then
    echo "Docker must be running"
    exit
fi

docker-compose -f src/test/resources/docker-compose.yml up

popd