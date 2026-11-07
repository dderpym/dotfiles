{ config, lib, ... }:

# Machine-specific values shared between modules. Read as config.machine here
# and as osConfig.machine from home-manager modules.
{
  options.machine = {
    rootDevice = lib.mkOption {
      type = lib.types.str;
      description = "Root filesystem device; also the hibernate resume target.";
    };
    keyboardEvent = lib.mkOption {
      type = lib.types.str;
      default = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
      description = "Built-in keyboard evdev node.";
    };
    backlight = lib.mkOption {
      type = lib.types.str;
      default = "intel_backlight";
      description = "Backlight name under /sys/class/backlight.";
    };
    externalUsbControllers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "0000:00:14.0" "0000:00:0d.0" ];
      description = "PCI addresses of xHCI controllers that must not wake from sleep.";
    };
  };

  config.machine.rootDevice = config.fileSystems."/".device;
}
