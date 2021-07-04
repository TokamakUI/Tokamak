#include "type_check.h"

gboolean tokamak_gtk_widget_is_container(GtkWidget *widget) {
  return GTK_IS_CONTAINER(widget);
}

gboolean tokamak_gtk_widget_is_stack(GtkWidget *widget) {
  return GTK_IS_STACK(widget);
}