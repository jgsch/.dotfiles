{ config, ... }:

{
  # Enable OpenGL / graphics
  hardware.graphics.enable = true;

  # Load NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required for Wayland compositors (COSMIC)
    modesetting.enable = true;

    # Use the open source kernel module (requires Turing+ GPU, i.e. RTX 20xx or newer)
    # Set to false if you have an older GPU or experience issues
    open = true;

    # Enable the nvidia-settings menu
    nvidiaSettings = true;

    # Use the stable driver package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
