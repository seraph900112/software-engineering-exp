//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <eyro_toast/eyro_toast_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) eyro_toast_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "EyroToastPlugin");
  eyro_toast_plugin_register_with_registrar(eyro_toast_registrar);
}
