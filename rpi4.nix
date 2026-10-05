{ config, pkgs, lib, secrets, ... }:
{
  networking.hostName = "rpi4";
  time.timeZone = "Asia/Shanghai";
  system.stateVersion = "26.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.useNetworkd = true;
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "end* eth* en*";
    address = [ "192.168.100.50/24" ];
    routes = [ { Gateway = "192.168.100.1"; } ];
    dns = [ "192.168.100.1" "223.5.5.5" ];
  };

  networking.wireless.enable = true;
  networking.wireless.networks."${secrets.wifiSSID}".psk = secrets.wifiPSK;
  systemd.network.networks."20-wifi" = {
    matchConfig.Name = "wlan0";
    networkConfig.DHCP = "yes";
    dhcpV4Config.RouteMetric = 300;
  };

  # 代理（与服务器集群同款，显式声明；机房断网时代理自然失效，靠国内镜像兜底）
  environment.variables = {
    HTTP_PROXY  = "http://192.168.100.1:7890";
    HTTPS_PROXY = "http://192.168.100.1:7890";
    http_proxy  = "http://192.168.100.1:7890";
    https_proxy = "http://192.168.100.1:7890";
    NO_PROXY    = "127.0.0.1,localhost,192.168.0.0/16";
    no_proxy    = "127.0.0.1,localhost,192.168.0.0/16";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4o7cUdPevEr2IbmMoqv1Ws0eVmbhC2woy5VoFI7E9/ traversal@BUILDER-13"
  ];
  users.users.root.initialPassword = "nixos";
  users.users.root.shell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      ".." = "cd ..";
    };
    interactiveShellInit = ''
      HISTSIZE=10000
      SAVEHIST=10000
      HISTFILE=~/.zsh_history
      setopt AUTO_CD

      eval "$(zoxide init zsh)"

      rebuild() {
        cd /root/rpi4 && nixos-rebuild switch --flake .#rpi4
      }
      update() {
        cd /root/rpi4 && nix flake update && nixos-rebuild switch --flake .#rpi4
      }
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = ">";
        error_symbol = "x";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };
      git_branch = {
        symbol = "git:";
        style = "bold purple";
      };
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };
      time = {
        disabled = false;
        format = "[$time]($style) ";
        style = "bold white";
      };
    };
  };

  programs.zoxide.enable = true;

  environment.systemPackages = with pkgs; [
    git vim lazygit
    eza bat fd ripgrep fzf btop jq
  ];

  boot.blacklistedKernelModules = [ "vc4" ];
  sdImage.compressImage = false;
}
