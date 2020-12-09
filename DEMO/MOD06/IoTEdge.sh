sudo -s

# update Edge device hostname: Full DNS name
nano /etc/iotedge/config.yaml
# hostname: "az-220-vm-edgegw-{YOUR-ID}.eastus.cloudapp.azure.com"

# 使用连接字符串为 Azure IoT 中心配置 Edge 设备
/etc/iotedge/configedge.sh "{iot-edge-device-connection-string}"

# 列出当前在 IoT Edge 设备上运行的所有 IoT Edge 模块
iotedge list