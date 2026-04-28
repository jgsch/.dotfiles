{ config, ... }:

{
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Modesetting is required for Wayland compositors (COSMIC)
    modesetting.enable = true;
  };
}
