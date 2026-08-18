# Examples

Enable **Any Game Event Bus** in Project Settings > Plugins. It registers the `GaEventBus` autoload.

Other Midnight Anxiety plugins look up `/root/GaEventBus` at runtime and call `register_signal`, `emit_named`, and `connect_named`. They compile and run without this addon; enabling Event Bus is what wires them together.

```gdscript
# From your own game code, after Event Bus is enabled:
GaEventBus.player_look_switch.emit(false)
GaEventBus.show_warning.emit("Door locked", 2.0)
```
