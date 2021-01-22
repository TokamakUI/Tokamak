/** Returns name of a given unapplied generic type. `Button<Text>` and
 `Button<Image>` types are different, but when reconciling the tree of mounted views
 they are treated the same, thus the `Button` part of the type (the type constructor)
 is returned.
 */
func typeConstructorName(_ type: Any.Type) -> String {
  // FIXME: no idea if this calculation is reliable, but seems to be the only way to get
  // a name of a type constructor in runtime. Should definitely check if these are different
  // across modules, otherwise can cause problems with views with same names in different
  // modules.
  String(String(describing: type).prefix { $0 != "<" })
}
