#!/usr/bin/env bash

if [ -f local_parameters.sh ] ; then
    source local_parameters.sh
else
    echo "See Readme - local_paramters.sh needed"
    exit 1
fi

function build_docker_image {
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
    export JANUSGRAPH_VANILLA_SERVER_DIRNAME=janusgraph-${JANUSGRAPH_VERSION}-hadoop2
    export JANUSGRAPH_DYNAMODB_SERVER_ZIP=${JANUSGRAPH_DYNAMODB_SERVER_DIRNAME}.zip


    if [[ $CLEAN ]] ; then
        echo "Cleaning"
        rm -rf $WORKDIR
    fi

    if ! pgrep -f docker > /dev/null ; then
        echo "Docker must be running"
        exit
    fi

    if [ ! -d "server" ]; then
        echo "Building Docker Images using shipped build scripts - make a coffee!"
        src/test/resources/install-gremlin-server.sh
        ./bin/gremlin-server.sh -i org.apache.tinkerpop gremlin-python $TINKERPOP_VERSION
        python3 ../AddPythonSupportToJanus.py $JANUSGRAPH_SERVER_HOME/conf/gremlin-server/gremlin-server.yaml -o $JANUSGRAPH_SERVER_HOME/conf/gremlin-server/gremlin-server.yaml
        python3 ../AddPythonSupportToJanus.py $JANUSGRAPH_SERVER_HOME/conf/gremlin-server/gremlin-server-local.yaml -o $JANUSGRAPH_SERVER_HOME/conf/gremlin-server/gremlin-server-python-local.yaml
        python3 ../AddPythonSupportToJanus.py $JANUSGRAPH_SERVER_HOME/conf/gremlin-server/gremlin-server-local-docker.yaml -o $JANUSGRAPH_SERVER_HOME/conf/gremlin-server/gremlin-server-python-local-docker.yaml
        # As we've changed stuff need to recreate the zip the official script creates
        zip -rq $WORKDIR/${JANUSGRAPH_DYNAMODB_SERVER_ZIP} $WORKDIR/${JANUSGRAPH_DYNAMODB_SERVER_DIRNAME}
        cp $WORKDIR/dynamodb-janusgraph-storage-backend-*.zip src/test/resources/dynamodb-janusgraph-docker
        mvn docker:build -Pdynamodb-janusgraph-docker
    fi

    popd
}

function copy_cloud_formations {

    aws s3 cp cloudformation/ecs.yaml s3://$SCRIPT_BUCKET/ecs.yaml
    aws s3 cp cloudformation/ecs_task.yaml s3://$SCRIPT_BUCKET/ecs_task.yaml
    aws s3 cp cloudformation/random_input.yaml s3://$SCRIPT_BUCKET/random_input.yaml
    aws s3 cp cloudformation/vpc.yaml s3://$SCRIPT_BUCKET/vpc.yaml
    aws s3 cp dynamodb-janusgraph-storage-backend/dynamodb-janusgraph-tables-multiple.yaml s3://$SCRIPT_BUCKET/dynamodb-janusgraph-tables-multiple.yaml
    aws s3 cp cloudformation/rds.yaml s3://$SCRIPT_BUCKET/rds.yaml
    rm cloudformation/lambda_function.zip
    zip -Dj cloudformation/lambda_function.zip cloudformation-random-string/lambda_function.py
    aws s3 cp cloudformation/lambda_function.zip s3://$SCRIPT_BUCKET/lambda_function.zip

}

