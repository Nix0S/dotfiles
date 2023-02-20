#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix 
#   └─ ./hosts  
#       ├─ default.nix *
#       ├─ configuration.nix
#       ├─ home.nix
#       └─ ./desktop OR ./laptop OR ./work OR ./vm
#            ├─ ./default.nix
#            └─ ./home.nix 
#

{ lib, inputs, nixpkgs, home-manager, user, location,  ... }:

let
  system = "x86_64-linux";                                  # System architecture

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;                              # Allow proprietary software
  };

  lib = nixpkgs.lib;
in
{
  hydrogen = lib.nixosSystem {                               # Desktop profile
    inherit system;
    specialArgs = {
      inherit inputs user location;
      host = {
        hostName = "hydrogen";
        mainMonitor = "Virtual-1";
#        secondMonitor = "DP-1";
      };
    };                                                      # Pass flake variable
    modules = [                                             # Modules that are used.
      ./hydrogen
      ./configuration.nix

      home-manager.nixosModules.home-manager {              # Home-Manager module that is used.
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user;
          host = {
            hostName = "hydrogen";     #For Xorg iGPU  | Videocard 
            mainMonitor = "Virtual-1"; #HDMIA3         | HDMI-A-1
#            secondMonitor = "DP-1";   #DP1            | DisplayPort-1
          };
        };                                                  # Pass flake variable
        home-manager.users.${user} = {
          imports = [(import ./home.nix)] ++ [(import ./hydrogen/home.nix)];
        };
      }
    ];
  };
}