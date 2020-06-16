import JavaScriptKit
import TokamakDOM

let document = JSObjectRef.global.document.object!

let divElement = document.createElement!("div").object!
let renderer = DOMRenderer(Button("button", action: { print("hello") }), divElement)

let body = document.body.object!
_ = body.appendChild!(divElement)
