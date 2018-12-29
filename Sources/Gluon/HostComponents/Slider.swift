//
//  Slider.swift
//  Gluon
//
//  Created by Max Desiatov on 29/12/2018.
//

public struct SliderProps: Equatable, EventHandlerProps, ValueControlProps {
  public let handlers: [Event: Handler<()>]
  public let value: Float
  public let valueHandler: Handler<Float>?
}

public struct Slider: HostComponent {
  public typealias Props = SliderProps
  public typealias Children = Null
}
