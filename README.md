﻿
[toc]
<center> <h1>FISCO BCOS物料包工具使用指南</h1> </center>

# 一. 介绍
## 1.1 功能简介        
通过简单配置 ,可以在指定服务器上构建FISCO BCOS的区块链, 构成FISCO BCOS的节点既可以直接运行于服务器, 也可以是docker节点。 可以非常快速的搭建临时使用的测试环境, 又能满足生产环境的需求。  
例如：  
配置三台服务器, 每台启动两个FISCO BCOS节点, 则将生成三个安装包, 对应三台服务器, 将安装包上传到对应的服务器上, 继续按照指引安装, 在每台服务器上启动节点, 就可以组成一个区块链网络。

## 1.2. 术语简介  
* 两种节点类型：**创世节点, 非创世节点**。
* **创世节点**：搭建一条新链时, 配置文件的第一台服务器上的第一个节点为创世节点, 创世节点是需要第一个启动的节点, 其他节点需要主动连接创世节点, 通过与创世节点的连接, 所有节点同步连接信息, 最终构建正常的网络。
* **非创世节点**：除去创世节点的其它节点。

## 1.3. 依赖  
- 机器配置  
   参考FISCO BCOS[机器配置](https://github.com/FISCO-BCOS/FISCO-BCOS/tree/master/doc/manual#第一章-部署fisco-bcos环境)  
   ```
   使用的测试服务器： 
   CentOS 7.2 64位
   CentOS 7.4 64位
   Ubuntu 16.04 64位
   ```
  
- 软件依赖  

```shell
Oracle JDK[1.8]
```

**依赖说明**
- FISCO BCOS搭建过程中需要的其他依赖会自动安装, 用户不需要再手动安装.
- CentOS/Ubuntu默认安装或者使用yum/apt安装的是openJDK, 并不符合使用要求, Oracle JDK 1.8 的安装链接[[ Oracle JDK 1.8 安装]](https://github.com/ywy2090/fisco-package-build-tool/blob/docker/doc/Oracle%20JAVA%201.8%20%E5%AE%89%E8%A3%85%E6%95%99%E7%A8%8B.md).

- 其他依赖  
  sudo权限, 当前执行的用户需要具有sudo权限

## 1.4 版本支持

物料包与FISCO BCOS之间存在版本对应关系,
**物料包1.2.X版本对应支持FISCO BCOS的版本为: 1.3.X  
即物料包1.2的版本兼容支持FISCO BCOS1.3的版本.**

## 1.5 CheckList
[CheckList](https://github.com/ywy2090/fisco-package-build-tool/blob/docker/doc/%E7%89%A9%E6%96%99%E5%8C%85%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BACheckList.md)使用物料包之前可以使用CheckList文档对当前环境进行检查, 尤其是生产环境时建议将CheckList作为一个必备的流程.
 
# 二. <a name="buildblockchain" id="buildblockchain">部署区块链</a>  
本章节会通过一个示例说明如何使用物料包工具, 也会介绍使用物料包构建好的环境中比较重要的一些目录
如果你希望快速搭建fisco bcos测试环境，请转至第四章部署区块链sample.
## 2.1 下载物料包  


```shell
$ git clone https://github.com/FISCO-BCOS/fisco-package-build-tool.git
```
目录结构以及主要配置文件作用： 
```
fisco-package-build-tool
├── Changelog.md                       更新记录       
├── config.ini                         配置文件
├── doc                                附加文档
├── ext                                拓展目录
├── generate_installation_packages.sh  启动shell文件
├── installation_dependencies          依赖目录
├── LICENSE                            license文件
├── README.md                          使用手册
└── release_note.txt                   版本号
```

## 2.2 配置

```shell
$ cd fisco-package-build-tool
$ vim config.ini
```

配置文件config.ini
```
[common]
; 物料包拉取FISCO-BCOS源码的github地址.
github_url=https://github.com/FISCO-BCOS/FISCO-BCOS.git
; 物料包拉取FISCO-BCOS源码之后, 会将源码保存在本地的目录, 保存的目录名称为FISCO-BCOS.
fisco_bcos_src_local=../
; 需要使用FISCO-BCOS的版本号, 使用物料包时需要将该值改为需要使用的版本号.
; 版本号可以是FISCO-BCOS已经发布的版本之一, 链接： https://github.com/FISCO-BCOS/FISCO-BCOS/releases
fisco_bcos_version=v1.3.3

; 节点信息
[nodes]
; 格式为 : nodeIDX=p2p_ip listen_ip num agent
; IDX为索引, 从0开始增加.
; p2p_ip     => 服务器上用于p2p通信的网段的ip.
; listen_ip  => 服务器上的监听端口, 用来接收rpc、channel的链接请求, 建议默认值为"0.0.0.0".
; num        => 在服务器上需要启动的节点的数目.
; agent      => 机构名称, 若是不关心机构信息, 值可以随意, 但是不可以为空.
node0=127.0.0.1  0.0.0.0  4  agent

;端口配置, 一般不用做修改, 使用默认值即可.
[ports]
; p2p端口
p2p_port=30303
; rpc端口
rpc_port=8545
; channel端口
channel_port=8821

; 扩容使用的一些参数
[expand]
genesis_follow_dir=/follow/

[docker]
; 当前是否构建docker节点的安装包. 0: 否    1：是
docker_toggle=0
; docker仓库地址.
docker_repository=fiscoorg/fisco-octo
; docker版本号.
docker_version=v1.3.x-latest

; 生成web3sdk证书时使用的keystore与clientcert的密码.
; 也是生成的web3sdk配置文件applicationContext.xml中keystorePassWord与clientCertPassWord的值.
[web3sdk]
keystore_pwd=123456
clientcert_pwd=123456

[other]
; CA拓展, 目前不需要关心
ca_ext=0
``` 

### 2.2.1 <a name="configuration" id="configuration">配置详解</a>    
#### [common] section
```
[common]
; 物料包拉取FISCO-BCOS源码的github地址.
github_url=https://github.com/FISCO-BCOS/FISCO-BCOS.git
; 物料包拉取FISCO-BCOS源码之后, 会将源码保存在本地的目录, 保存的目录名称为FISCO-BCOS.
fisco_bcos_src_local=../
; 需要使用FISCO-BCOS的版本号, 使用物料包时需要将该值改为需要使用的版本号.
; 版本号可以是FISCO-BCOS已经发布的版本之一, 链接： https://github.com/FISCO-BCOS/FISCO-BCOS/releases
fisco_bcos_version=v1.3.2
```

- 物料包在构建安装包过程中(非扩容流程), 会启动一个默认的临时temp节点用来部署进行系统合约的部署, 将所有的节点注册到节点管理合约, 然后导出导出系统合约信息生成genesis.json文件。
- 在扩容流程中, 需要手动将扩容节点注册到节点管理合约, 参考后面的扩容流程。
- 每个节点启动时需要占用三个端口: p2p、rpc、channel. 对于启动的临时节点temp节点, 使用就是配置的nodes section中的p2p_port、rpc_port、channel_port配置端口, 要确认端口没有被占用。
- 对于FISCO BCOS节点, 每台服务器上第一个节点使用nodes section配置的p2p_port、rpc_port、channel_port端口, 后续的节点端口依次进行端口递增.
- 工具构建安装包过程中会涉及到从github上面拉取FISCO BCOS、编译FISCO BCOS流程, 规则：  
a、检查/usr/local/bin是否已经存在已经编译的fisco-bcos。  
b、若存在则查看fisco-bcos的版本号与配置fisco_bcos_version字段的版本号是否一致, 一致则说明fisco-bcos是需要的版本, 该流程退出.  
c、判断配置文件中fisco_bcos_src_local配置的路径是否存在名为FISCO-BCOS的文件夹, 存在说明FISCO-BCOS源码已经存在, 否则开始从github上面拉取FISCO BCOS源码, 接下来进入FISCO-BCOS目录切换tag到自己需要的分支, 然后进行编译、安装流程, 成功则fisco-bcos会安装在/usr/local/bin目录下。

#### [docker] section

与docker节点搭链相关的配置, 参考附录。

#### [web3sdk] section

与私钥跟证书文件的加解密相关。生成web3sdk证书时使用的keystore与clientcert的密码, 也是生成的web3sdk配置文件applicationContext.xml中keystorePassWord与clientCertPassWord的值, **强烈建议用户修改这两个值**。

#### [expand] section
扩容操作, 使用参考 ( [扩容流程](#expand_blockchain) )

#### [nodes] section
```
需要部署FISCO BCOS服务器上的节点配置信息.
[nodes]
; 格式为 : nodeIDX=p2p_ip listen_ip num agent
; IDX为索引, 从0开始增加.
; p2p_ip     => 服务器上用于p2p通信的网段的ip.
; listen_ip  => 服务器上的监听端口, 用来接收rpc、channel的链接请求, 建议默认值为"0.0.0.0".
; num        => 在服务器上需要启动的节点的数目.
; agent      => 机构名称, 若是不关心机构信息, 值可以随意, 但是不可以为空.
```

#### [ports] section  
```
[ports]
; p2p端口
p2p_port=30303
; rpc端口
rpc_port=8545
; channel端口
channel_port=8821
```
fisco-bcos的每个节点需要使用3个端口,p2pport、rpcport、channelport,  [ports]配置的端口是服务器上面的第一个节点使用的端口,其他节点依次递增.
```
node0=127.0.0.1 0.0.0.0 4 agent
````
上面的配置说明要启动四个节点, 按照默认的配置：
- 第1个节点的端口：p2p 30303、rpc 8545、channel 8821   
- 第2个节点的端口：p2p 30304、rpc 8546、channel 8822  
- 第3个节点的端口：p2p 30305、rpc 8547、channel 8823  
- 第4个节点的端口：p2p 30306、rpc 8548、channel 8824 


下面以在三台服务器上部署区块链为例构建一条新链： 
```
服务器ip  ： 172.20.245.42 172.20.245.43 172.20.245.44  
机构分别为： agent_0   agent_1    agent_2  
节点数目  ： 每台服务器搭建两个节点
```

修改[nodes] section字段为：
```
[nodes]
node0=172.20.245.42  0.0.0.0  2  agent_0
node1=172.20.245.43  0.0.0.0  2  agent_1
node2=172.20.245.44  0.0.0.0  2  agent_2
```

## 2.3 创建安装包  
```
$ ./generate_installation_packages.sh build
```
执行成功之后会生成build目录, 目录下有生成的对应服务器的安装包：
```
build/
├── 172.20.245.42_agent_0_genesis  //172.20.245.42服务器的安装包
├── 172.20.245.43_agent_1          //172.20.245.43服务器的安装包
├── 172.20.245.44_agent_2          //172.20.245.44服务器的安装包
├── stderr.log      //标准错误的重定向文件.
└── temp            //temp节点安装目录, 用户不用关心不用关心.
```

* 其中带有**genesis**字样的为创世节点所在服务器的安装包。 

## 2.4 上传  
* 将安装包上传到对应的服务器, 注意上传的安装包必须与服务器相对应, 否则部署过程会出错。
* 一定要确认各个服务器之间的网络可连通, p2p网段的端口网络策略已经放开。

## 2.5 安装  
进入安装目录, 执行
```sh
$ ./install_node.sh 
```
正确执行在当前目录会多一个build目录, 目录结构如下：
```

build
├── check.sh          #检查脚本, 可以检查节点是否启动
├── fisco-bcos        #fisco-bcos二进制程序
├── node0             #节点0的目录
├── node1             #节点1的目录
├── nodejs            #nodejs相关安装目录
├── node_manager.sh   #节点管理脚本
├── node.sh           #nodejs相关环境变量
├── register.sh       #注册节点入网脚本, 扩容使用
├── start.sh          #启动脚本
├── stop.sh           #停止脚本
├── systemcontract    #nodejs系统合约工具
├── tool              #nodejs工具
├── unregister.sh     #从节点管理合约删除某个节点
├── web3lib           #nodejs基础库
└── web3sdk           #web3sdk环境
```

说明:
- nodeIDX
节点IDX的目录, 示例中每台服务器启动两个节点, 所以有node0, node1两个目录.
nodeIDX的目录结构如下：
```
build/node0/
├── check.sh     #检查当前节点是否启动
├── config.json  #配置文件
├── data         #数据目录
├── genesis.json #创世块文件
├── keystore
├── log          #log日志目录
├── log.conf     #log配置文件
├── start.sh     #启动当前节点
└── stop.sh      #停止当前节点
```

- node.sh
记录nodejs相关依赖的环境变量.
- start.sh
节点启动脚本, 使用方式：
```
start.sh       启动所有的节点
或者
start.sh IDX   启动指定的节点, IDX为节点的索引, 从0开始, 比如: start.sh 0表示启动第0个节点.
```
- stop.sh
节点停止脚本, 使用方式：
```
stop.sh       停止所有的节点
或者
stop.sh IDX   停止指定的节点, IDX为节点的索引, 从0开始, 比如: stop.sh 0表示停止第0个节点.
```
- register.sh
注册指定节点信息到节点管理合约, 扩容时使用
```
register.sh IDX
```
- unregister.sh
将指定节点从节点管理合约中删除.
```
unregister.sh IDX
```
- node_manager.sh
查看当前节点管理合约中的节点信息.
```
./node_manager.sh all
```
[[web3sdk使用说明链接]](https://github.com/FISCO-BCOS/web3sdk)  
[[web3lib、systemcontract、 tool目录作用参考用户手册]](https://github.com/FISCO-BCOS/FISCO-BCOS/tree/master/doc/manual)

## 2.6 启动节点

在build目录执行start.sh脚本.  
**注意:要先启动创世块节点所在的服务器上的节点!!!**

```sh
$ ./start.sh 
start all node ... 
start node0 ...
start node1 ...
check all node status ... 
node is running.
node is running.
```

## 2.7 验证

- **一定要所有服务器上的节点正常启动之后.**

### 2.7.1 日志

```shell
tail -f node0/log/log_*.log  | egrep "Generating seal"
INFO|2018-08-03 14:16:42:588|+++++++++++++++++++++++++++ Generating seal on8e5add00c337398ac5e9058432037aa646c20fb0d1d0fb7ddb4c6092c9d654fe#1tx:0,maxtx:1000,tq.num=0time:1522736202588
INFO|2018-08-03 14:16:43:595|+++++++++++++++++++++++++++ Generating seal ona98781aaa737b483c0eb24e845d7f352a943b9a5de77491c0cb6fd212c2fa7a4#1tx:0,maxtx:1000,tq.num=0time:1522736203595
```
可看到周期性的出现上面的日志，表示节点间在周期性的进行共识，整个链正常。

### 2.7.2 部署合约

每个服务器执行install_node时, 都会在安装目录下安装nodejs、babel-node、ethconsole, 其环境变量会写入当前安装用户的.bashrc文件，使用这些工具之前需要使环境变量生效，有两种使环境变量生效的方式，选择其中一种即可：

方式1：退出当前登录, 重新登录一次.
方式2：执行node.sh脚本中的内容, 首先cat node.sh, 将显示的内容执行一遍.
```
$ cat node.sh 
export NODE_HOME=/root/octo/fisco-bcos/build/nodejs; export PATH=$PATH:$NODE_HOME/bin; export NODE_PATH=$NODE_HOME/lib/node_modules:$NODE_HOME/lib/node_modules/ethereum-console/node_modules;
$ export NODE_HOME=/root/octo/fisco-bcos/build/nodejs; export PATH=$PATH:$NODE_HOME/bin; export NODE_PATH=$NODE_HOME/lib/node_modules:$NODE_HOME/lib/node_modules/ethereum-console/node_modules;
```

部署合约验证, 进入tool目录： 
```
$ cd tool
$ babel-node deploy.js HelloWorld
RPC=http://127.0.0.1:8546
Ouputpath=./output/
deploy.js  ........................Start........................
Soc File :HelloWorld
HelloWorldcomplie success！
send transaction success: 0xfb6237b0dab940e697e0d3a4d25dcbfd68a8e164e0897651fe4da6a83d180ccd
HelloWorldcontract address 0x61dba250334e0fd5804c71e7cbe79eabecef8abe
HelloWorld deploy success!
cns add operation => cns_name = HelloWorld
         cns_name =>HelloWorld
         contract =>HelloWorld
         version  =>
         address  =>0x61dba250334e0fd5804c71e7cbe79eabecef8abe
         abi      =>[{"constant":false,"inputs":[{"name":"n","type":"string"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"}]
send transaction success: 0x769e4ea7742b451e33cbb0d2a7d3126af8f277a52137624b3d4ae41681d58687
```
合约部署成功。

## 2.8 问题排查
参考附录FAQ.

# 三. <a name="expand_blockchain" id="expand_blockchain">扩容流程</a>

- **扩容流程与搭链流程最本质的差别是, 初次搭链时会生成一个temp节点, 进行系统合约的部署, 然后会将所有构建的节点信息都注册入节点管理合约, 最后temp节点导出生成genesis.json文件. 所以搭链结束后, 每个节点信息都已经在节点管理合约, 但是在扩容时, 需要自己注册扩容的节点到节点管理合约。(参考FISCO-BCOS系统合约介绍[[节点管理合约]](https://github.com/FISCO-BCOS/Wiki/tree/master/FISCO-BCOS%E7%B3%BB%E7%BB%9F%E5%90%88%E7%BA%A6%E4%BB%8B%E7%BB%8D#%E8%8A%82%E7%82%B9%E7%AE%A1%E7%90%86%E5%90%88%E7%BA%A6))。**

## 3.1 使用场景  
对已经在运行的区块链, 可以提供其创世节点的相关文件, 创建出非创世节点, 使其可以连接到这条区块链。
## 3.2 获取扩容文件   
- 从创世节点所在的服务器获取dependencies/follow/文件夹.
该目录包含构建区块链时分配的根证书、机构证书、创世块文件、系统合约.

将follow放入/fisco-bcos/目录.

## 3.3. 配置

扩容的机器为: 172.20.245.45, 172.20.245.46 分别需要启动两个节点, 机构名称分别为agent_3、agent_4, 修改节点信息配置.
```sh
vim config.ini
```

修改扩容参数
```
; 扩容使用的一些参数
[expand]
genesis_follow_dir=/fisco-bcos/follow/
```

修改节点列表为扩容的节点信息.
```
[nodes]
node0=172.20.245.45  0.0.0.0  2  agent_3
node1=172.20.245.46  0.0.0.0  2  agent_4
```

## 3.4. 扩容 
```
./generate_installation_packages.sh expand
```
成功之后会输出`Expanding end!`并在build目录生成对应安装包
```
build
├── 172.20.245.45_with_0.0.0.0_installation_package
├── 172.20.245.46_with_0.0.0.0_installation_package
└── stderr.log
```

## 3.5 安装启动  
将安装包分别上传至对应服务器, 分别在每台服务器上面执行下列命令：  
- 执行安装
```
./install_node.sh
```
- 启动节点
```
cd build
./start.sh
```

## 3.6 节点入网  

**在扩容时, 当前运行的链已经有数据, 当前新添加扩容的节点首先要进行数据同步, 建议新添加的节点在数据同步完成之后再将节点入网. 数据是否同步完成可以查看新添加节点的块高是否跟其他节点已经一致.**

以172.20.245.45这台服务器为例进行操作, 172.20.245.46操作类似：

**确保节点先启动.**   
用户在build目录下，使用register.sh脚本进行注册操作
注册
```
$ ./register.sh 0  # 注册第一个节点
$ ./register.sh 1  # 注册第二个节点
```

验证,注册的节点是否正常:
```
$ tail -f node0/log/log_*.log   | egrep "Generating seal"
INFO|2018-07-10 10:49:29:818|+++++++++++++++++++++++++++ Generating seal oncf8e56468bab78ae807b392a6f75e881075e5c5fc034cec207c1d1fe96ce79a1#4tx:0,maxtx:1000,tq.num=0time:1531190969818
INFO|2018-07-10 10:49:35:863|+++++++++++++++++++++++++++ Generating seal one23f1af0174daa4c4353d00266aa31a8fcb58d3e7fbc17915d95748a3a77c540#4tx:0,maxtx:1000,tq.num=0time:1531190975863
INFO|2018-07-10 10:49:41:914|+++++++++++++++++++++++++++ Generating seal on2448f00f295210c07b25090b70f0b610e3b8303fe0a6ec0f8939656c25309b2f#4tx:0,maxtx:1000,tq.num=0time:1531190981914
INFO|2018-07-10 1
```

## 3.7 问题排查
参考附录FAQ.

# 四. 部署区块链sample 
这里提供一个非常简单的例子, 用来示例使用本工具如何以最快的速度搭建一条在单台服务器上运行4个节点的FISCO BCOS的测试环境，
如果需要手动配置部署区块链请转到第三章。

假设当前用户的环境比较干净, 并没有修改配置文件config.ini。

## 4.1 下载物料包
```
$ git clone https://github.com/FISCO-BCOS/fisco-package-build-tool.git
```

## 4.2 生成安装包
```
$ cd fisco-package-build-tool
$ ./generate_installation_packages.sh build
......
//中间会有FISCO-BCOS下载、编译、安装, 时间会比较久, 执行成功最终在当前目录下会生成build目录.
......
```
查看生成的build目录结构
```
$ tree -L 1 build
build/
├── 127.0.0.1_with_0.0.0.0_genesis_installation_package
├── stderr.log
└── temp
```
其中 127.0.0.1_with_0.0.0.0_genesis_installation_package 即是生成的安装包.

## 4.3 安装
假定需要将FISCO BCOS安装在当前用户home目录下, 安装的目录名fisco-bcos。
```
$ mv build/127.0.0.1_with_0.0.0.0_genesis_installation_package ~/fisco-bcos
$ cd ~/fisco-bcos
$ ./install_node.sh
..........
执行成功会生成build目录
```

## 4.4 启动  
```
$ cd build
$ ./start.sh
start node0 ...
start node1 ...
start node2 ...
start node3 ...
check all node status => 
node0 is running.
node1 is running.
node2 is running.
node3 is running.
```

## 4.5 验证  
```
$ tail -f node0/log/log_2018080116.log | egrep "seal"
INFO|2018-08-01 16:52:18:362|+++++++++++++++++++++++++++ Generating seal on5b14215cff11d4b8624246de63bda850bcdead20e193b24889a5dff0d0e8a3c3#1tx:0,maxtx:1000,tq.num=0time:1533113538362
INFO|2018-08-01 16:52:22:432|+++++++++++++++++++++++++++ Generating seal on5e7589906bcbd846c03f5c6e806cced56f0a17526fb1e0c545b855b0f7722e14#1tx:0,maxtx:1000,tq.num=0time:1533113542432
```

## 4.6 部署成功  
Ok, 一条简单的测试链已经搭建成功。

## 4.7 问题排查
参考附录FAQ.

# <a name="Appendix" id="Appendix">附录</a>
## 一、构建docker运行环境
### 1.1 说明
使用物料包同样可以构建基于docker节点的区块链的搭建, 使用方式与构建普通节点的区块链比较类似, 区别在于最终启动的docker节点. 
### 1.2 配置
```
[docker]
; 当前是否构建docker节点的安装包. 0：否    1：是
docker_toggle=1
; docker仓库地址.
docker_repository=fiscoorg/fisco-octo
; docker版本号.
docker_version=v1.3.x-latest
```
- docker_toggle   
构建docker节点环境时, docker_toggle设置为1.
- docker_repository  
docker镜像仓库, 用户一般不需要修改.
- docker_version  
docker版本号, 使用默认值即可, 版本更新时, 本地可以自动更新至最新版本.

### 1.3 配置节点信息

同样以在三台服务器上部署区块链为例：

服务器ip  ： 172.20.245.42 172.20.245.43 172.20.245.44  
机构分别为： agent_0   agent_1    agent_2  
节点数目  ： 每台服务器搭建两个节点
修改[nodes] section字段为：

```
[nodes]
node0=172.20.245.42  0.0.0.0  2  agent_0
node1=172.20.245.43  0.0.0.0  2  agent_1
node2=172.20.245.44  0.0.0.0  2  agent_2
```

### 1.4 构建安装包

执行成功会输出``` Building end!  ``` 并生成build目录.
```
build/
├── 172.20.245.42_agent_0_genesis
├── 172.20.245.43_agent_1
├── 172.20.245.44_agent_2
├── stderr.log
└── temp
```

将安装包上传到对应的服务器.

### 1.5 安装
进入安装目录, 执行``` ./install_node ```, 成功之后会生成 **docker** 目录.
```
docker/
├── node0
├── node1
├── register0.sh
├── register1.sh
├── start0.sh
├── start1.sh
├── start.sh
├── stop0.sh
├── stop1.sh
├── stop.sh
├── unregister0.sh
└── unregister1.sh
```

- nodeIDX : 第IDX个节点的目录, 该目录会被映射到docker的/fisco-bcos/node/目录, 这两个目录中的内容是一致的.
- nodeIDX/log : 日志目录.
- start.sh 启动所有的docker节点.
- stop.sh 停止所有的docker节点.
- startIDX.sh 启动第IDX个docker节点.
- stopIDX.sh 停止第IDX个节点.
- registerIDX.sh 扩容时使用, 将第IDX个节点注册入节点管理合约, 调用的是docker中的node_manager.sh脚本, 扩容时使用.
- unregisterIDX.sh 将IDX个节点从节点管理合约删除, 调用的是node_manager.sh脚本.

### 1.6 启动
在docker目录执行start.sh脚本  
**注意:要先启动创世块节点所在的服务器上的节点!!!**
```
 ./start.sh 
start node0 ...
705b6c0e380029019a26e954e72da3748e29cec95a508bc1a8365abcfc36b86c
start node1 ...
be8bd964322a08a70f22be9ba15082dbe50d1729f955291586a0503e32d2225f
```

### 1.7 验证

#### docker ps
通过docker ps命令查看docker节点是否启动正常.
```
docker ps  -f name="fisco*"
CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS              PORTS               NAMES
be8bd964322a        fiscoorg/fisco-octo:v1.3.x-latest   "/fisco-bcos/start_n…"   21 minutes ago      Up 21 minutes                           fisco-node1_8546
705b6c0e3800        fiscoorg/fisco-octo:v1.3.x-latest   "/fisco-bcos/start_n…"   22 minutes ago      Up 22 minutes                           fisco-node0_8545
```
启动的两个docker节点的容器id分别为: be8bd964322a、705b6c0e3800, docker节点的STATUS状态为Up, 说明节点正常启动.

#### 日志验证
```
tail -f node0/log/log_*.log | egrep "seal"
INFO|2018-08-13 11:52:38:534|PBFTClient.cpp:343|+++++++++++++++++++++++++++ Generating seal onec61bbf7cb6152d523f391dfe65dd1f858ec3daa7b6df697308a0ad5219cf232#1tx:0,maxtx:1000,tq.num=0time:1534161158534
INFO|2018-08-13 11:52:40:550|PBFTClient.cpp:343|+++++++++++++++++++++++++++ Generating seal on127962f94ccb075a448ae741e69718ffc0bee4f97ccddb7bd5e8a0310f4b8980#1tx:0,maxtx:1000,tq.num=0time:1534161160550
INFO|2018-08-13 11:52:42:564|PBFTClient.cpp:343|+++++++++++++++++++++++++++ Generating seal on29ccca512d7e2bac34760e8c17807896dac914b426884a0bc28499a556811467#1tx:0,maxtx:1000,tq.num=0time:1534161162564
```
说明节点周期性共识, 出块.

#### 进入docker容器部署合约.  
docker运行之后, docker镜像内部是一个完整的fisco-bcos的运行环境, 包括js的工具都是可用的, 可以进入docker镜像内部进行合约的部署.
以be8bd964322a为例.
```
$ sudo docker exec -it be8bd964322a /bin/bash
```

#### 加载环境变量

执行 ``` source /etc/profile ```加载docker内部的一些环境变量.

#### 目录
```
$ cd /fisco-bcos
```

目录结构如下：
```
/fisco-bcos/
├── node
│   ├── config.json
│   ├── fisco-data   
│   ├── genesis.json
│   ├── log
│   └── start.sh
├── tool
├── systemcontract
├── web3sdk
├── nodejs
├── web3lib
└── nodejs
```
- /fisco-bcos/node             : 节点目录
- /fisco-bcos/node/fisco-data  : 数据目录
- /fisco-bcos/node/log         : 日志目录
- /fisco-bcos/systemcontract   : nodejs系统合约工具.  
- /fisc-bcos/tool              : nodejs工具.  
- /fisco-bcos/web3lib          : nodejs基础库.  
- /fisco-bcos/web3sdk          : web3sdk环境.

#### 部署合约
进入tool目录, 部署合约
```
$ cd /fisco-bcos/tool
$ babel-node deploy.js HelloWorld     
RPC=http://0.0.0.0:8546
Ouputpath=./output/
deploy.js  ........................Start........................
Soc File :HelloWorld
HelloWorldcomplie success！
send transaction success: 0x726e328e5b53ddb3ce040424304ffd61e9ae277d6441068c45ad590003c7426a
HelloWorldcontract address 0x4437f8c9cd1e6a3e8ec9c3460c4bc209acdca052
HelloWorld deploy success!
cns add operation => cns_name = HelloWorld
         cns_name =>HelloWorld
         contract =>HelloWorld
         version  =>
         address  =>0x4437f8c9cd1e6a3e8ec9c3460c4bc209acdca052
         abi      =>[{"constant":false,"inputs":[{"name":"n","type":"string"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"}]
send transaction success: 0xa280d823346e1b7ea332a2b4d7a7277ae380b0cc7372bef396c5205fa74b25ae
```

### 1.8 扩容.

与普通节点的扩容流程类似, 大体来说, 构建扩容安装包, 启动节点, 将扩容的节点入网(加入节点管理合约).

#### 1.8.1 构建扩容安装包
参考 [三. 扩容流程](#expand_blockchain) 构建扩容机器上的安装包.

#### 1.8.2 安装启动
将扩容服务器上传对应的服务器, 进入安装目录, 执行``` ./install_node ```
执行成功之后生成**docker**目录.
启动docker节点
```
$ cd docker
$ ./start.sh
```

#### 1.8.3 节点入网
docker目录下``` registerIDX.sh ```脚本为注册脚本.
```
$ ./register0.sh
===================================================================
=====INIT ECDSA KEYPAIR From private key===
node.json=file:/fisco-bcos/node/fisco-data/node.json
$ ./register1.sh
===================================================================
=====INIT ECDSA KEYPAIR From private key===
node.json=file:/fisco-bcos/node/fisco-data/node.json
```

#### 1.8.4 验证
查看log
```
 tail -f node0/log/log*.log | egrep "seal"
INFO|2018-08-13 12:00:18:710|PBFTClient.cpp:343|+++++++++++++++++++++++++++ Generating seal on26c826ad8d275cd2c3c53a034818acce222ad7dc8ef455de64efbf193748c9ef#1tx:0,maxtx:1000,tq.num=0time:1534161618710
INFO|2018-08-13 13:00:02:040|PBFTClient.cpp:343|+++++++++++++++++++++++++++ Generating seal onb7a72e68cbc43293dac635b3c868e83ecbe24c3f1b72e0d57a809ee72bad9ca5#4tx:0,maxtx:0,tq.num=0time:1534165202040
INFO|2018-08-13 13:54:25:054|PBFTClient.cpp:343|+++++++++++++++++++++++++++ Generating seal one2d93621481bf613b065f254519bbc32689d3b2eb8c5a1680c0f4d57531f7ef5#5tx:0,maxtx:0,tq.num=0time:1534168465054
```

## 二、私钥证书管理
- 物料包使用FISCO BCOS的工具分配证书, 工具位于下载的FISCO-BCOS目录的cert子目录, 使用方式参考[FISCO-BCOS 证书生成工具](https://github.com/FISCO-BCOS/FISCO-BCOS/tree/master/doc/manual#第二章-准备链环境)。
- 构建完成各个服务器的安装包之后, 整条链的根证书、机构证书会保存在创世节点所在服务器的dependencies/cert目录 保存的目录结构为： 
```
cert目录  
    ca.crt 
    ca.key
    机构名称子目录
        agency.crt
        agency.key
```

- 以上面示例的配置为例,  创世节点服务器cert目录内容(省略了一些不重要的文件)：
```
ca.crt
ca.key
agent_0\
    agency.crt
    agency.key
agent_1\
    agency.crt
    agency.key
agent_2\
    agency.crt
    agency.key
```
- ca.crt 根证书
- ca.key 根证书私钥
- agent_0\agency.crt agent_0机构证书 
- agent_0\agency.key agent_0机构证书私钥
- agent_1\agency.crt agent_1机构证书 
- agent_1\agency.key agent_1机构证书私钥
- agent_2\agency.crt agent_2机构证书 
- agent_2\agency.key agent_2机构证书私钥

## 三、物料包其他工具配置

### [物料包JAVA配置](https://github.com/FISCO-BCOS/fisco-package-build-tool/blob/master/doc/Oracle%20JAVA%201.8%20%E5%AE%89%E8%A3%85%E6%95%99%E7%A8%8B.md)
FISCO BCOS中需要使用Oracle JDK 1.8(java 1.8)环境，在CentOS/Ubuntu中默认安装或者通过yum/apt安装的JDK均为openJDK，并不符合使用的要求，本文是一份简单的Oracle Java 1.8的安装教程。

### [物料包web3sdk配置](https://github.com/FISCO-BCOS/fisco-package-build-tool/blob/master/doc/web3sdk.md)
物料包内置了配置好的web3sdk以及相关的环境，用户可以直接使用web3sdk。请注意，由于物料包已经生成好了链证书和机构证书，因此物料包中的web3sdk的证书配置与源码编译略有不同。

### [监控脚本monitor.sh的使用](https://github.com/FISCO-BCOS/fisco-package-build-tool/blob/dev/doc/monitor.md)
monitor.sh可以用来监控节点是否正常启动, 以及整条链是否正常工作, 详情使用参考链接.

### [日志清理脚本rmlogs.sh的使用](https://github.com/FISCO-BCOS/fisco-package-build-tool/blob/dev/doc/rmlogs.md)
rmlogs.sh可以用来清理fisco-bcos产生的日志文件, 具体参考链接使用文档.

### [物料包环境checklist](https://github.com/FISCO-BCOS/fisco-package-build-tool/blob/master/doc/%E7%89%A9%E6%96%99%E5%8C%85%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BACheckList.md)
通常我们推荐使用物料包[FISCO BCOS物料包]搭建FISCO BCOS的环境，可以屏蔽搭建过程中的一些繁琐细节。

物料包使用时，本身存在一些依赖, 同时FISCO BCOS对网络、yum源等外部环境也存在依赖，为减少搭建过程中遇到的问题，建议在使用之前对整个搭建的环境进行检查，特别是生产环境的搭建，尤其推荐CheckList作为一个必备的流程。

# <a name="FAQ" id="FAQ">FAQ</a>

## generate_installation_packages.sh build/expand 报错提示
- ERROR - build directory already exist, please remove it first.  

fisco-package-build-tool目录下已经存在build目录, 可以将build目录删除再执行。
- ERROR - no sudo permission, please add youself in the sudoers.  
 
当前登录的用户需要有sudo权限。
- ERROR - Unsupported or unidentified Linux distro.  
  
当前linux系统不支持, 目前FISCO-BCOS支持CentOS 7.2+、Ubuntu 16.04。
- ERROR -Unsupported or unidentified operating system.
  
当前系统不支持, 目前FISCO-BCOS支持CentOS 7.2+、Ubuntu 16.04。
- ERROR - Unsupported Ubuntu Version. At least 16.04 is required.  
  
当前ubuntu版本不支持, 目前ubuntu版本仅支持ubuntu 16.04 64位操作系统。
- ERROR - Unsupported CentOS Version. At least 7.2 is required.  
  
当前CentOS系统不支持, 目前CentOS支持7.2+ 64位。
- ERROR - Unsupported Oracle Linux, At least 7.4 Oracle Linux is required.  

当前CentOS系统不支持，目前CentOS支持7.2+ 64位。
- ERROR - unable to determine CentOS Version

当前CentOS系统不支持, 目前CentOS支持7.2+ 64位。
- ERROR - Unsupported Linux distribution.

不支持的linux系统.目前FISCO-BCOS支持CentOS 7.2+、Ubuntu 16.04。
- ERROR - Oracle JDK 1.8 be requied  
  
需要安装Oracle JDK 1.8。目前物料包的web3sdk仅支持Oracle JDK1.8版本，尚未支持其他的java版本，请参考[物料包java安装](https://fisco-bcos-test.readthedocs.io/zh/latest/docs/tools/oracle_java.html)
- ERROR - OpenSSL 1.0.2 be requied  
  
物料包需要openssl 1.0.2版本，请升级openssl版本。
- ERROR - failed to get openssl version
  
无法获取openssl的版本，请尝试从新安装openssl。 
- ERROR - XXX is not installed. 
   
XXX没有安装，请尝试安装该依赖。
- ERROR - FISCO BCOS gm version not support yet.  
  
物料包不支持国密版本的FISCO BCOS的安装。
- ERROR - At least FISCO-BCOS 1.3.0 is required.  
  
物料包工具支持的FISCO BCOS的版本最低为v1.3.0。
- ERROR - Required version is xxx, now fisco bcos version is xxxx" 
   
当前fisco-bcos版本与配置的版本不一致, 建议手动编译自己需要的版本。
- ERROR - node.nodeid is not exist.
- ERROR - ca.crt is not exist
- ERROR - maybe  bash *.sh

无法为当前node生成证书，请检查证书文件是否完好。

- ERROR - temp node rpc port check, *** is in use
- ERROR - temp node channel port check, *** is in use
- ERROR - temp node p2p port check, *** is in use
  
rpc/channel/p2p port被占用，请尝试修改端口号从新进行安装。
- ERROR - temp node rpc port check, XXX is in use.  
  
temp节点使用的rpc端口被占用, 可以netstat -anp | egrep XXX查看占用的进程。
- ERROR - temp node channel port check, XXX is in use.  
  
temp节点使用的channel端口被占用, 可以netstat -anp | egrep XXX查看占用的进程。 
- ERROR - temp node p2p port check, XXX is in use.  
  
temp节点使用的p2p端口被占用, 可以netstat -anp | egrep XXX查看占用的进程。
- ERROR - git clone FISCO-BCOS failed.  
  
下载FISCO-BCOS源码失败, 建议手动下载。 
- ERROR - system contract address file is not exist, web3sdk deploy system contract not success.  
  
temp节点部署系统合约失败。
- ERROR - Oracle JDK 1.8 be requied, now JDK is `java -version`.

- ERROR - there has no node on this server.

当前服务器没有任何节点，请至少为一台服务器至少配置一个节点。
- ERROR - fisco-bcos --newaccount opr faild.

god账户配置失败，请从新尝试安装。
- ERROR - channel port is not listening.

部署系统合约失败，请更新物料包版本。
- ERROR - system contract address file is not exist, web3sdk deploy system contract not success.

系统合约部署失败，请检查java jdk配置是否正确。
- ERROR - system contract address file is empty, web3sdk deploy system contract not success.

系统合约部署失败，请从新下载物料包。
## docker 安装报错提示

- ERROR - docker is not installed
docker未安装, 用户需要自己安装docker程序, apt/yum install docker.

- ERROR - docker dictionary already exist, remove it first.
 
docker目录已存在，请移除当前docker节点安装包目录之后重试。

- ERROR - docker pull failed, docker service not start or repository？version info error,repository.

docker服务器启动失败，请检查docker配置、运行是否正常。
- ERROR - there is already fisco-bcos docker named fisco-node.

当前docker内已经有名称已存在的文件夹，请更改名称。
## generate_installation_packages.sh build/expand 直接退出。
查看build/stderr.log内容, 查看错误信息。

## start.sh 提示 ulimit: core file size: cannot modify limit: Operation not permitted
无法通过脚本修改core文件大小限制, 不影响节点的启动。

## start.sh 显示nodeIDX is not running.  
这个提示是说nodeIDX启动失败, 可以ps -aux | egrep fisco 查看是否正常启动. 可以执行`cat node/nodedirIDX/log/log`查看节点启动失败的原因。

常见的原因:
- libleveldb.so No such file or directory.
```
./fisco-bcos: error while loading shared libraries: libleveldb.so.1: cannot open shared object file: No such file or directory 
```
leveldb动态库缺失, 安装脚本里面默认使用 yum/apt 对依赖组件进行安装, 可能是 yum/apt 源缺失该组件。 

可以使用下面命令手动安装leveldb, 若leveldb安装不成功可以尝试替换yum/apt的源。
```
[CentOS]sudo yum -y install leveldb-devel
[Ubuntu]sudo apt-get -y install libleveldb-dev

```  
如果leveldb已经安装, 则可以尝试执行`sudo ldconfig`, 然后执行start.sh, 重新启动节点.

- FileError
```
terminate called after throwing an instance of 'boost::exception_detail::clone_impl<dev::FileError>' what():  FileError
```

操作文件失败抛出异常, 原因可能是当前登录的用户没有安装包目录的权限, 可以通过ls -lt查看当前文件夹对应的user/group/other以及对应的权限, 一般可以将安装包的user改为当前用户或者切换登录用户为安装包的user用户可以解决问题。

