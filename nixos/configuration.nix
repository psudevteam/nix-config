# Beast Nix Config

{ config, pkgs, ... }:

{
  # Include the results of the hardware scan.
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enviroment Variable
  environment.variables = {
    NIXOS_CONFIG="$HOME/.config/nixos/configuration.nix";
    NIXOS_CONFIG_DIR="$HOME/.config/nixos/";
    PATH="$HOME/.npm-packages/bin:$PATH";
  };

  # Enable Nix Overlay
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
    (final: prev: {
      dwm = prev.dwm.overrideAttrs (old: { src = /home/ms/.config/dwm;});
    })
  ];

  # Enable Natural Scrolling
  services.xserver.libinput.touchpad.naturalScrolling = true;

  # Enable Auto Upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Enable Auto Run Programs
  systemd.user.services.foo = {
    script = ''
      pkill picom
      picom -b --experimental-backends
      nitrogen --restore
      setxkbmap -option caps:swapescape
    '';
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
  };

  # Enable Unfree Repository
  nixpkgs.config.allowUnfree = true;

  # Disable XTERM
  services.xserver.desktopManager.xterm.enable = false;

  # Enable Opengl
  hardware.opengl.enable = true;

  # Enable Virtualization
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Enable ZSH and set as Default Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
 
  # Set Hostname
  networking.hostName = "beast";

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # DHCP Set always to false because is deprecated
  networking.useDHCP = false;

  # Set interface especially wireless interface to get DHCP
  networking.interfaces.wlp3s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set Fonts on Terminal
  console = {
     font = "FiraCode Nerd Font Mono";
     keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable/Disable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # Enable DWM
  services.xserver.windowManager.dwm.enable = true;
  
  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable PipeWire as Sound Server.
  hardware.pulseaudio.enable = false;
  sound.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  services.pipewire = {
  config.pipewire-pulse = {
    "context.properties" = {
      "log.level" = 2;
    };
    "context.modules" = [
      {
        name = "libpipewire-module-rtkit";
        args = {
          "nice.level" = -15;
          "rt.prio" = 88;
          "rt.time.soft" = 200000;
          "rt.time.hard" = 200000;
        };
        flags = [ "ifexists" "nofail" ];
      }
      { name = "libpipewire-module-protocol-native"; }
      { name = "libpipewire-module-client-node"; }
      { name = "libpipewire-module-adapter"; }
      { name = "libpipewire-module-metadata"; }
      {
        name = "libpipewire-module-protocol-pulse";
        args = {
          "pulse.min.req" = "32/48000";
          "pulse.default.req" = "32/48000";
          "pulse.max.req" = "32/48000";
          "pulse.min.quantum" = "32/48000";
          "pulse.max.quantum" = "32/48000";
          "server.address" = [ "unix:native" ];
        };
      }
    ];
    "stream.properties" = {
      "node.latency" = "32/48000";
      "resample.quality" = 1;
     };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ms = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" "libvirtd"  ];
  };
  
  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # List packages installed in system profile
   environment.systemPackages = with pkgs; [
     vim
     wget
     curl
     git
     gnome3.gnome-tweaks
     virt-manager
     networkmanager
     dmenu
     alacritty
     tdesktop
     nitrogen
     xorg.xbacklight
   ];

  # Some programs need SUID wrappers
  programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

