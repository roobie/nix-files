# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  mySecrets = import /root/nixos-secrets.nix;
in
  assert mySecrets.user != "";
  assert mySecrets.hostname != "";
  assert mySecrets.hostId != "";
  assert mySecrets.domain != "";
  assert mySecrets.tz != "";

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # for networking in/with virtual machines
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "${mySecrets.tz}";
  # Enable ntp or rather timesyncd
  services.timesyncd = {
    enable = true;
    servers = [ "0.de.pool.ntp.org" "1.de.pool.ntp.org" "2.de.pool.ntp.org" "3.de.pool.ntp.org" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  # in order to make slock work, it has to have the security wrapper enabled
  # security.wrappers.slock.source = "${pkgs.slock.out}/bin/slock";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Setup networking
  networking = {
        # IPv6?
        enableIPv6 = true;
        # hostName = "${mySecrets.hostname}"; # Define your hostname.
        hostName = "${mySecrets.hostname}";
        domain = "${mySecrets.domain}";
        search = ["${mySecrets.domain}"];
        hostId = "${mySecrets.hostId}";
        # networkmanager.enable = true;
        firewall.allowPing = true;
        useDHCP = true;
        interfaces = {
          # enp0s25 = {
          #   ipv4.addresses = [
          #     {
          #       address = "192.168.1.99";
          #       prefixLength = 24;
          #     }
          #   ];
          # };
          # virbr0 = {
          #   ipv4.addresses = [
          #     {
          #       address = "192.168.2.1";
          #       prefixLength = 24;
          #     }
          #     # { address = "192.168.1.1"; prefixLength = 24; }
          #   ];
          #   ipv4.routes = [
          #     {
          #       address = "192.168.2.0";
          #       prefixLength = 24;
          #       via = "192.168.1.1";
          #     }
          #   ];
          # };
          # eth1 = {
          #   ipv4.addresses = [
          #     { address = "10.0.0.2"; prefixLength = 16; }
          #     # { address = "192.168.1.1"; prefixLength = 24; }
          #   ];
          # };
          # tap0 = {
          #   virtual = true;
          #   virtualOwner = "bjorn";
          #   virtualType = "tap";
          # };
          # tap1 = {
          #   virtual = true;
          #   virtualOwner = "bjorn";
          #   virtualType = "tap";
          # };
          # tap2 = {
          #   virtual = true;
          #   virtualOwner = "bjorn";
          #   virtualType = "tap";
          # };
        };
        bridges = {
          br0 = {
            interfaces = [ "enp0s25" ];
            # interfaces = [ "tap0" "tap1" "tap2" ];
          };
        };
        # firewall.allowedUDPPorts = [ 5000 5001 21025 21026 22000 22026 5959 45000 ];
        # firewall.allowedTCPPorts = [ 5000 5001 22000 5959 45000 ];
        # firewall.allowedTCPPorts = [ 12913 ];
        # Netcat: 5000
        # IPerf: 5001
        # Syncthing: 21025 21026 22000 22026
        # SPICE/VNC: 5900
        # WebProxify: 5959
        # nginx: 4500
        # wireguard = {
          # interfaces = {
            # ips = ["192.168.1.200/30"];
            # peers = [
              # {
                # allowedIPs = [];
                # endpoint = "br-net.wireguard.io:12913";
                # publicKey = "Rnc1F6I8ib9LJXkOXqs7yRsBny4DwrLESPakRODpfF8=";
                # privateKey = "2GFDtTWoA/VtjU9yaSKfXVh10/iyWEn1BB/cczMsCHI=";
              # }
            # ];
          # };
          # wg0 = {
            # allowedIPsAsRoutes = true;
            # ips = [ "192.168.1.132" ];
          # };
        # };
        extraHosts = ''
          # Get ad server list from: https://pgl.yoyo.org/adservers/
          ${builtins.readFile (builtins.fetchurl {
            name = "blocked_hosts.txt";
            url = "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext";
          })}
          127.0.0.1       protectedinfoext.biz
        '';
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.opengl.enable = true;

  services.dnsmasq.enable = true;
  services.dnsmasq.resolveLocalQueries = true;
  services.dnsmasq.servers = [ "208.67.220.220" "208.67.222.222", "8.8.8.8" ];
  services.dnsmasq.extraConfig = ''
# see https://wiki.archlinux.org/index.php/Dnsmasq
# see http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq.conf.example
# Never forward plain names (without a dot or domain part)
domain-needed

# Never forward addresses in the non-routed address spaces.
bogus-priv

# only listen on the physical ethernet interface
interface=br0

# Set this (and domain: see below) if you want to have a domain
# automatically added to simple names in a hosts-file.
expand-hosts

# Set the domain for dnsmasq. this is optional, but if it is set, it
# does the following things.
# 1) Allows DHCP hosts to have fully qualified domain names, as long
#     as the domain part matches this setting.
# 2) Sets the "domain" DHCP option thereby potentially setting the
#    domain of all systems configured by DHCP
# 3) Provides the domain part for "expand-hosts"
domain=br-home.net

# local domain
local=/lan/
domain=lan

# set announce dhcp
dhcp-option=6,192.168.1.99

dhcp-range=192.168.1.110,192.168.10.254,24h
# static assign
# dhcp-host=00:27:0E:02:A8:AE,192.168.10.100

# this machine is not the internet gateway, so specify the router here
dhcp-option=3,192.168.1.1
  '';

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "ctrl:nocaps";
  services.xserver = {
    enable = true;
    videoDrivers = [ "nouveau" "intel" ];
    layout = "us";
    xkbOptions = "ctrl:nocaps";
    # synaptics = {
    #     enable = true;
    # };
    # Enable touchpad support.
    libinput = {
      enable = true;
    };

    # Enable the KDE Desktop Environment.
    # displayManager.sddm = {
      # enable = true;
      # autoLogin = {
        # enable = true;
        # user = "${mySecrets.user}";
      # };
    # };
    displayManager.lightdm = {
      enable = true;
      # extraSeatDefaults = ''
      # display-setup-script=/usr/share/setup-monitors.sh
      # session-setup-script=/usr/share/setup-monitors.sh
      # '';
    };
    # displayManager.gdm = {
      # enable = true;
      # wayland = true;
    # };
    # displayManager.session = [
      # {
        # manage = "window";
        # name = "sway";
        # start = ''
        # ${pkgs.sway}/bin/sway
        # '';
      # }
    # ];
    # desktopManager.plasma5.enable = true;
    windowManager.dwm.enable = true;
    windowManager.i3.enable = true;
    # windowManager.xmonad.enable = true;

    # xrandrHeads = [
    #   {
    #     output = "HDMI3";
    #     primary = true;
    #   }
    #   {
    #     output = "HDMI2";
    #     primary = false;
    #     monitorConfig = ''
    #     Option "RightOf" "HDMI3"
    #     '';
    #   }
    # ];
  };

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.slim.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.windowManager.dwm.enable = true;
  # services.xserver.windowManager.xmonad.enable = true;

  programs = {
    ssh.startAgent = true;
    fish.enable = true;
    # sway.enable = true;
  };
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  security.sudo.enable = true;
  security.sudo.extraRules = [
    { commands = [ "ALL" ] ; groups = [ "sudo" ] ; }
  ];
  # allow qemu IFs to be managed without password
  security.sudo.extraConfig = ''
User_Alias QEMUERS = bjorn
Cmnd_Alias QEMU = /etc/qemu-ifup, /etc/qemu-ifdown
QEMUERS ALL=(ALL) NOPASSWD: QEMU
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bjorn = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "sudo"
      "networkmanager"
      "netdev"
      "libvirtd"
      # "sway"
    ];
    shell = pkgs.fish;
  };
  users.groups = {
    netdev = {};
    networkmanager = {};
    libvirtd = {};
  };

  fonts = {
        enableFontDir = true;
        # enableCoreFonts = true;
        enableGhostscriptFonts = true;
        fonts = with pkgs ; [
            liberation_ttf
            ttf_bitstream_vera
            dejavu_fonts
            terminus_font
            bakoma_ttf
            clearlyU
            cm_unicode
            andagii
            bakoma_ttf
            inconsolata
            gentium
            ubuntu_font_family
            source-sans-pro
            source-code-pro
            fira-code
        ];
  };

  virtualisation.libvirtd.enable = true;

  # Enable Syncthing
  # services.syncthing = {
        # enable = true;
        # dataDir = "/home/${mySecrets.user}/Desktop/Syncthing";
        # user = "${mySecrets.user}";
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    dmenu
    file
    lshw
    lsof
    neovim
    nix-index
    nix-info
    ntfs3g
    tmux
    vim
    wget
    wireguard
    wireguard-tools
  ];
}
