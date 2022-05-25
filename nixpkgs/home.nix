{ config, pkgs, ... }:
let
   picom_overlay = (self: super: {
     picom = super.picom.overrideAttrs (prev: {
       version = "git";
       src = pkgs.fetchFromGitHub {
         owner = "yshui";
         repo = "picom";
         rev = "31e58712ec11b198340ae217d33a73d8ac73b7fe";
         sha256 = pkgs.lib.fakeSha256;
       };
     });
   });
in
{
   home.username = "ms";
   home.homeDirectory = "/home/ms";
   home.stateVersion = "21.11";
   nixpkgs.overlays = [ picom_overlay ];
   programs.home-manager.enable = true;
   programs.light.enable = true;
   programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
      ];
   };
   programs.alacritty.enable = true;
   programs.git = {
     enable = true;
     userName  = "Maulana Sodiqin";
     userEmail = "maulana@pmg.id";
   };
   programs.zsh = {
     enable = true;
     enableCompletion = true;
     enableAutosuggestions = true;
     enableSyntaxHighlighting = true;
     oh-my-zsh = {
       enable = true;
       plugins = [ "git" ];
       theme = "awesomepanda";
     };
     shellAliases = {
       ll = "ls -l";
       c = "clear";
       update = "sudo nixos-rebuild switch";
     };
     history = {
       size = 10000;
       path = "${config.xdg.dataHome}/zsh/history";
     };
   };
}
