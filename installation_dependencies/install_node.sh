#!/bin/bash

#set -x
#set -e

#public config
installPWD=$PWD
DEPENENCIES_DIR=$installPWD/dependencies
source $DEPENENCIES_DIR/scripts/utils.sh
source $DEPENENCIES_DIR/scripts/public_config.sh
source $DEPENENCIES_DIR/scripts/os_version_check.sh
source $DEPENENCIES_DIR/scripts/dependencies_install.sh
source $DEPENENCIES_DIR/scripts/dependencies_check.sh

source $DEPENENCIES_DIR/config.sh
g_is_genesis_host=${is_genesis_host}

# build stop_node*.sh
function generate_stopsh_func()
{
    stopsh="#!/bin/bash
    weth_pid=\`ps aux|grep \"${NODE_INSTALL_DIR}/node${Idx[$index]}/config.json\"|grep -v grep|awk '{print \$2}'\`
    kill_cmd=\"kill -9 \${weth_pid}\"
    if [ ! -z \$weth_pid ];then
        echo \"stop node${Idx[$index]} ...\"
        eval \${kill_cmd}
    else
        echo \"node${Idx[$index]} is not running.\"
    fi"
    echo "$stopsh"
    return 0
}

# build check_node*.sh
function generate_checksh_func()
{
    checknodesh="#!/bin/bash
    weth_pid=\`ps aux|grep \"${NODE_INSTALL_DIR}/node${Idx[$index]}/config.json\"|grep -v grep|awk '{print \$2}'\`
    if [ ! -z \$weth_pid ];then
        echo \"node\$1 is running.\"
    else
        echo \"node\$1 is not running.\"
    fi"
    echo "$checknodesh"
}

# build start_node*.sh
function generate_startsh_func()
{
    startsh="#!/bin/bash
    weth_pid=\`ps aux|grep \"${NODE_INSTALL_DIR}/node${Idx[$index]}/config.json\"|grep -v grep|awk '{print \$2}'\`
    if [ ! -z \$weth_pid ];then
        echo \"node${Idx[$index]} is running, pid is \$weth_pid.\"
    else
        echo \"start node${Idx[$index]} ...\"
        nohup ./fisco-bcos  --genesis ${NODE_INSTALL_DIR}/node${Idx[$index]}/genesis.json  --config ${NODE_INSTALL_DIR}/node${Idx[$index]}/config.json  >> ${NODE_INSTALL_DIR}/node${Idx[$index]}/log/log 2>&1 &
    fi"
    echo "$startsh"
    return 0
}

function build_tools()
{
    cp $DEPENENCIES_DIR/monitor/monitor.sh $installPWD/
    chmod +x $installPWD/monitor.sh
}

function install_build()
{
    echo "    Installing fisco-bcos environment start"

    #check sudo permission
    request_sudo_permission
    # operation system check
    os_version_check
    # java version check
    java_version_check

    sudo chown -R $(whoami) $installPWD

    if [ -d $buildPWD ];then
        error_message "build dictinary already exist, remove it first."
    fi

    if [ -z $nodecount ] ||[ $nodecount -le 0 ]; then
        error_message "there has no node on this server, count is "$nodecount
    fi

    print_dash

    #dependencies check
    install_dependencies_check

    #mkdir node dir
    current_node_dir_base=${NODE_INSTALL_DIR}
    mkdir -p ${current_node_dir_base}

    i=0
    while [ $i -lt $nodecount ]
    do
        index=$i
        current_node_dir=${current_node_dir_base}/node${Idx[$index]}
        mkdir -p $current_node_dir/
        mkdir -p $current_node_dir/log/
        mkdir -p $current_node_dir/keystore/
        mkdir -p $current_node_dir/data/

        if [ $i -eq 0 ];then
            #copy web3sdk
            cp -r $DEPENENCIES_WEB3SDK_DIR ${buildPWD}
            sudo chmod a+x ${buildPWD}/web3sdk/bin/web3sdk
            cp $DEPENDENCIES_RLP_DIR/node_rlp_${Idx[$index]}/ca/sdk/* ${buildPWD}/web3sdk/conf/ >/dev/null 2>&1 #ca info copy
            if [ $g_is_genesis_host -eq 1 ];then
                cp $DEPENDENCIES_TPL_DIR/empty_bootstrapnodes.json ${current_node_dir}/data/bootstrapnodes.json >/dev/null 2>&1
            else
                cp $DEPENENCIES_FOLLOW_DIR/bootstrapnodes.json ${current_node_dir}/data/ >/dev/null 2>&1
            fi
        else
            cp $DEPENENCIES_FOLLOW_DIR/bootstrapnodes.json ${current_node_dir}/data/ >/dev/null 2>&1
        fi

        #copy node ca
        cp $DEPENDENCIES_RLP_DIR/node_rlp_${Idx[$index]}/ca/node/* ${current_node_dir}/data/
        # cp $DEPENENCIES_FOLLOW_DIR/bootstrapnodes.json ${current_node_dir}/data/ >/dev/null 2>&1

        nodeid=$(cat ${current_node_dir}/data/node.nodeid)
        echo "node id is "$nodeid

        #genesis.json
        cp $DEPENENCIES_FOLLOW_DIR/genesis.json ${current_node_dir}
        
        # generate log.conf from tpl
        export OUTPUT_LOG_FILE_PATH_TPL=${current_node_dir}/log
        MYVARS='${OUTPUT_LOG_FILE_PATH_TPL}'
        envsubst $MYVARS < ${DEPENDENCIES_TPL_DIR}/log.conf.tpl > ${current_node_dir}/log.conf

        export CONFIG_JSON_SYSTEM_CONTRACT_ADDRESS_TPL=$(cat $DEPENENCIES_FOLLOW_DIR/syaddress.txt)
        export CONFIG_JSON_LISTENIP_TPL=${listenip[$index]}
        export CRYPTO_MODE_TPL=${crypto_mode}
        export CONFIG_JSON_RPC_PORT_TPL=${rpcport[$index]}
        export CONFIG_JSON_P2P_PORT_TPL=${p2pport[$index]}
        export CHANNEL_PORT_VALUE_TPL=${channelPort[$index]}
        export CONFIG_JSON_KEYS_INFO_FILE_PATH_TPL=${current_node_dir}/keys.info
        export CONFIG_JSON_KEYSTORE_DIR_PATH_TPL=${current_node_dir}/keystore/
        export CONFIG_JSON_FISCO_DATA_DIR_PATH_TPL=${current_node_dir}/data/
        export CONFIG_JSON_FISCO_LOGCONF_DIR_PATH_TPL=${current_node_dir}/log.conf

        MYVARS='${CHANNEL_PORT_VALUE_TPL}:${CONFIG_JSON_SYSTEM_CONTRACT_ADDRESS_TPL}:${CONFIG_JSON_LISTENIP_TPL}:${CRYPTO_MODE_TPL}:${CONFIG_JSON_RPC_PORT_TPL}:${CONFIG_JSON_P2P_PORT_TPL}:${CONFIG_JSON_KEYS_INFO_FILE_PATH_TPL}:${CONFIG_JSON_KEYSTORE_DIR_PATH_TPL}:${CONFIG_JSON_FISCO_DATA_DIR_PATH_TPL}:${CONFIG_JSON_FISCO_LOGCONF_DIR_PATH_TPL}'
        envsubst $MYVARS < ${DEPENDENCIES_TPL_DIR}/config.json.tpl > ${current_node_dir}/config.json

        generate_startsh=`generate_startsh_func`
        echo "${generate_startsh}" > ${current_node_dir}/start.sh
        generate_stopsh=`generate_stopsh_func`
        echo "${generate_stopsh}" > ${current_node_dir}/stop.sh
        generate_checksh_func=`generate_checksh_func`
        echo "${generate_checksh_func}" > ${current_node_dir}/check.sh

        chmod +x ${current_node_dir}/start.sh
        chmod +x ${current_node_dir}/stop.sh
        chmod +x ${current_node_dir}/check.sh

        i=$(($i+1))
    done

    cp $DEPENENCIES_SCRIPTES_DIR/start.sh $buildPWD/
    sudo chmod a+x $buildPWD/start.sh

    cp $DEPENENCIES_SCRIPTES_DIR/stop.sh $buildPWD/
    sudo chmod a+x $buildPWD/stop.sh

    cp $DEPENENCIES_SCRIPTES_DIR/check.sh $buildPWD/
    sudo chmod a+x $buildPWD/check.sh

    cp $DEPENENCIES_SCRIPTES_DIR/register.sh $buildPWD/
    sudo chmod a+x $buildPWD/register.sh

    cp $DEPENENCIES_SCRIPTES_DIR/unregister.sh $buildPWD/
    sudo chmod a+x $buildPWD/unregister.sh

    cp $DEPENENCIES_SCRIPTES_DIR/node_manager.sh $buildPWD/
    sudo chmod a+x $buildPWD/node_manager.sh

    #fisco-bcos
    cp $DEPENENCIES_FISCO_DIR/fisco-bcos $current_node_dir_base
    #chmod a+x fisco-bcos
    sudo chmod a+x $current_node_dir_base/fisco-bcos

    print_install_result "fisco-solc"

    # fisco-solc
    sudo cp $DEPENENCIES_DIR/solc/fisco-solc /usr/local/bin/
    sudo chmod a+x /usr/local/bin/fisco-solc

    #web3sdk config
    export WEB3SDK_CONFIG_IP=${listenip[0]}
    export WEB3SDK_CONFIG_PORT=${channelPort[0]}
    export WEB3SDK_SYSTEM_CONTRACT_ADDR=$(cat $DEPENENCIES_FOLLOW_DIR/syaddress.txt)
    export KEYSTORE_PWD=${keystore_pwd}
    export CLIENTCERT_PWD=${clientcert_pwd}
    MYVARS='${CLIENTCERT_PWD}:${KEYSTORE_PWD}:${WEB3SDK_CONFIG_IP}:${WEB3SDK_CONFIG_PORT}:${WEB3SDK_SYSTEM_CONTRACT_ADDR}'
    echo "WEB3SDK_CONFIG_PORT=${channelPort[0]}"
    echo "WEB3SDK_SYSTEM_CONTRACT_ADDR=$(cat $DEPENENCIES_FOLLOW_DIR/syaddress.txt)"
    echo "KEYSTORE_PWD="${KEYSTORE_PWD}
    echo "CLIENTCERT_PWD="${CLIENTCERT_PWD}
    envsubst $MYVARS < $DEPENENCIES_DIR/tpl_dir/applicationContext.xml.tpl > ${WEB3SDK_INSTALL_DIR}/conf/applicationContext.xml

    print_dash

    echo "    Installing fisco-bcos success!"

    return 0
}

install_build

