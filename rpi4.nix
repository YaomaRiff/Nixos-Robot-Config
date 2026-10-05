# Raspberry Pi 4 定制 SD 镜像配置（机器人底系统）
# 背景：官方 25.11 镜像在本机出现启动后间歇卡死 + 无 DHCP（vc4 嫌疑）
# 本镜像：静态地址 + SSH 公钥 + 禁用 vc4，烧录后无需显示器/键盘
{ config, pkgs, lib, ... }:

{
  networking.hostName = "rpi4";
  time.timeZone = "Asia/Shanghai";
  system.stateVersion = "26.05";

  # 静态地址，避开 OpenWrt DHCP 动态段(.100-.200)
  networking.useNetworkd = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "end* eth* en*";
    address = [ "192.168.100.50/24" ];
    routes = [ { Gateway = "192.168.100.1"; } ];
    dns = [ "192.168.100.1" "223.5.5.5" ];
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4o7cUdPevEr2IbmMoqv1Ws0eVmbhC2woy5VoFI7E9/ traversal@BUILDER-13"
  ];
  # console 兜底密码（平时用不到，SSH 是 key 登录）
  users.users.root.initialPassword = "nixos";

  # 排除 vc4 KMS 卡死嫌疑，反正无头
  boot.blacklistedKernelModules = [ "vc4" ];

  # 镜像不压缩（压缩要在模拟器下跑，省时间；Rufus 直接写 .img）
  sdImage.compressImage = false;
}
