# dcmp use fabric example

### 1. 取dcmp 门户的Access Management页面选择接入key 导出

![image-20240401135406212](README.assets/image-20240401135406212.png)

### 2. 解压下载得到的zip文件

可以得到`接入节点地址`和`接入证书信息`

接入节点地址： 可以在下面文件中的excel文件中获取,  获取文件中 grpc 地址： grpcs://192.168.1.66:32444

接入证书信息： 可以在peerkess.zip中获取，里面包含msp和tls两个目录

### 3. 使用fabric-gateway进行接入

可以参考`fabric-gateway`官方说明。<a href="https://hyperledger-fabric.readthedocs.io/en/latest/gateway.html" target="_blank">了解更多</a>

具体例子可以参考：https://github.com/helailiang/dcmp/tree/main/dcmp-gateway

