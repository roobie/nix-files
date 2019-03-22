# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  mySecrets = import /root/nixos-secrets.nix;
in
  assert mySecrets.user != "";
  assert mySecrets.hostname != "";

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
  security.wrappers.slock.source = "${pkgs.slock.out}/bin/slock";

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
        hostId = "${mySecrets.hostId}";
        # enable = true;  # Enables wireless. Disable when using network manager
        networkmanager.enable = true;
        firewall.allowPing = true;
        # firewall.allowedUDPPorts = [ 5000 5001 21025 21026 22000 22026 5959 45000 ];
        # firewall.allowedTCPPorts = [ 5000 5001 22000 5959 45000 ];
        # Netcat: 5000
        # IPerf: 5001
        # Syncthing: 21025 21026 22000 22026
        # SPICE/VNC: 5900
        # WebProxify: 5959
        # nginx: 4500
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
	  # extraSeatDefaults = '' ''
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
    sway.enable = true;
  };
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

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
      "sway"
    ];
    shell = pkgs.fish;
  };

  # home-manager.users.bjorn = {
  #   programs.git = {enable = true; userName = "Bjorn Roberg"; userEmail = "bjorn.roberg@gmail.com";};
  # };

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
    dwm
    file
    firefox
    fish
    lshw
    lsof
    nix-index
    nix-info
    sway
    tmux
    vim
    wget
  ];
}
