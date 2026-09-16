{
  lib,
  pkgs,
  inputs,
  ...
}:

# COSMIC running on the niri compositor.
#
# Upstream: https://github.com/Drakulix/cosmic-ext-extra-sessions
#
# cosmic-session gained the ability to launch an alternative compositor in
# pop-os/cosmic-session#75, which is included in the 1.2.0 epoch shipped by
# nixpkgs, so no patched cosmic-session is required here.
#
# The only extra moving part is `cosmic-ext-alternative-startup`, which niri
# spawns at startup (see ~/.config/niri/config.kdl) to hand the COSMIC session
# the socket it expects.

let
  # "0-unstable-YYYY-MM-DD" from the flake input's lastModifiedDate.
  mkVersion =
    src:
    let
      d = src.lastModifiedDate;
    in
    "0-unstable-${lib.substring 0 4 d}-${lib.substring 4 2 d}-${lib.substring 6 2 d}";

  cosmic-ext-alternative-startup = pkgs.rustPlatform.buildRustPackage {
    pname = "cosmic-ext-alternative-startup";
    version = mkVersion inputs.cosmic-ext-alternative-startup;

    src = inputs.cosmic-ext-alternative-startup;
    cargoLock.lockFile = "${inputs.cosmic-ext-alternative-startup}/Cargo.lock";

    meta = {
      description = "Startup shim letting non-COSMIC compositors host a COSMIC session";
      homepage = "https://github.com/Drakulix/cosmic-ext-alternative-startup";
      license = lib.licenses.gpl3Only;
      mainProgram = "cosmic-ext-alternative-startup";
      platforms = lib.platforms.linux;
    };
  };

  cosmic-ext-niri-session = pkgs.stdenvNoCC.mkDerivation {
    pname = "cosmic-ext-niri-session";
    version = mkVersion inputs.cosmic-ext-extra-sessions;

    src = inputs.cosmic-ext-extra-sessions;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm0755 niri/start-cosmic-ext-niri $out/bin/start-cosmic-ext-niri
      install -Dm0644 niri/cosmic-ext-niri.desktop \
        $out/share/wayland-sessions/cosmic-ext-niri.desktop

      substituteInPlace $out/bin/start-cosmic-ext-niri \
        --replace-fail '#!/usr/bin/bash' '#!${pkgs.runtimeShell}' \
        --replace-fail 'exec bash -c' 'exec ${pkgs.runtimeShell} -c' \
        --replace-fail '/usr/bin/dbus-run-session' '${lib.getExe' pkgs.dbus "dbus-run-session"}' \
        --replace-fail '/usr/bin/cosmic-session' '${lib.getExe pkgs.cosmic-session}'

      substituteInPlace $out/share/wayland-sessions/cosmic-ext-niri.desktop \
        --replace-fail '/usr/local/bin/start-cosmic-ext-niri' \
          "$out/bin/start-cosmic-ext-niri"

      runHook postInstall
    '';

    # Must match the basename of the .desktop file above; the display-manager
    # module asserts on this.
    passthru.providedSessions = [ "cosmic-ext-niri" ];

    meta = {
      description = "COSMIC session running on the niri compositor";
      homepage = "https://github.com/Drakulix/cosmic-ext-extra-sessions";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
    };
  };
in
{
  programs.niri.enable = true;

  # Only pulled in for xdg-desktop-portal-gnome's file chooser; gtk's is fine.
  programs.niri.useNautilus = false;

  environment.systemPackages = [
    # niri spawns this at startup, so it has to be on PATH.
    cosmic-ext-alternative-startup

    # niri has no built-in XWayland; the nixpkgs module explicitly sets
    # enableXWayland = false. Without this, DISPLAY is unset in the session
    # and X11-only apps (VLC 3.x, among others) break. niri 26.04 detects
    # xwayland-satellite on PATH and spawns it on demand via -listenfd.
    pkgs.xwayland-satellite
  ];

  # Adds "COSMIC on niri" to cosmic-greeter.
  services.displayManager.sessionPackages = [ cosmic-ext-niri-session ];
}
