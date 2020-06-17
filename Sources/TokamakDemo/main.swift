import JavaScriptKit
import TokamakDOM

let document = JSObjectRef.global.document.object!

let divElement = document.createElement!("div").object!
let renderer = DOMRenderer(Counter(5), divElement)

let body = document.body.object!
_ = body.appendChild!(divElement)
