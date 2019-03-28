//
//  TextViewExample.swift
//  TokamakDemo-iOS
//
//  Created by Matvii Hodovaniuk on 3/27/19.
//  Copyright © 2019 Tokamak contributors. Tokamak is available under the
//  Apache 2.0 license. See the LICENSE file for more info.
//

import Tokamak

struct TextViewExample: LeafComponent {
  typealias Props = Null

  static func render(props: Props, hooks: Hooks) -> AnyNode {
    return StackView.node(.init(
      Edges.equal(to: .safeArea),
      axis: .vertical,
      distribution: .fillEqually
    ), [
      TextView.node(.init(text: ExampleText, textAlignment: .right)),
    ])
  }
}

let ExampleText = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit.Nam rhoncus eros eros,
id laoreet libero vehicula posuere.Etiam sit amet auctor mauris.In bibendum
rhoncus tincidunt.Nulla facilisis sagittis tellus, vitae tempus elit interdum
eget.Nam varius, velit ut condimentum suscipit, erat nunc molestie velit, a
feugiat metus ante sit amet quam.Phasellus lobortis risus ac urna sagittis
congue.Mauris vel eros lacus.Praesent sed feugiat felis, at ullamcorper
massa.Integer vitae iaculis turpis, in dapibus nunc.Fusce maximus fermentum
eros sed pellentesque.Mauris sed diam sed justo elementum iaculis non dignissim
erat.

Vivamus aliquam rutrum elementum.In at nulla ut enim vestibulum
gravida.Curabitur porttitor lorem eu risus venenatis iaculis.Curabitur vel
euismod nibh.Donec ante nisl, sagittis ac magna a, placerat aliquet
tortor.Vestibulum id tellus ut nulla egestas posuere.Ut non quam sed tellus
tempor elementum ac eu tellus.Ut metus tellus, molestie sit amet cursus sed,
fringilla vel erat.

Phasellus ultrices, magna eget eleifend molestie, sem odio congue tellus,
lobortis egestas orci lorem sit amet purus.Maecenas sed ante hendrerit, sodales
ligula non, iaculis augue.Ut sed aliquam metus, in malesuada arcu.Morbi tempor
lorem vitae turpis vehicula finibus.Fusce a rhoncus ipsum.Integer fermentum
lectus in erat facilisis, id imperdiet purus congue.Vestibulum egestas porta
tristique.Nulla at gravida dolor.Pellentesque id malesuada neque, elementum
hendrerit magna.Praesent at odio non magna sagittis porta.Vivamus tempus lacus
ac sem dignissim, sed cursus tortor suscipit.Nam laoreet et est non mollis.

Mauris mollis, lacus a bibendum venenatis, quam lectus ultrices turpis,
dignissim feugiat erat nisl non metus.Aliquam a ex semper, egestas velit non,
sagittis odio.Integer pharetra molestie turpis dictum fringilla.Vivamus
sollicitudin porta quam et porta.Nam lobortis tortor vel lectus accumsan, vel
commodo lorem fringilla.Orci varius natoque penatibus et magnis dis parturient
montes, nascetur ridiculus mus.Praesent porta, metus vitae fringilla dignissim,
nisl nisi ultrices arcu, nec volutpat quam nisi vitae elit.Donec vel nisl
vulputate, scelerisque ipsum ut, tempus erat.

Class aptent taciti sociosqu ad litora torquent per conubia nostra, per
inceptos himenaeos.Vestibulum ut turpis in eros scelerisque molestie.Ut aliquet
mauris lacinia mauris pretium placerat.Duis tempus nulla lectus, vitae eleifend
turpis semper eget.Integer in convallis odio.Fusce maximus consectetur
pharetra.Duis pharetra odio id neque mattis, ac aliquam velit dapibus.Ut
aliquam nisi vitae tortor varius fermentum eu ut enim.Nulla placerat erat vitae
diam scelerisque convallis.Sed sollicitudin commodo justo, ut ullamcorper orci
vulputate at.Proin aliquam, turpis nec euismod semper, dolor nibh rhoncus nibh,
quis condimentum eros purus eget ligula.
"""
