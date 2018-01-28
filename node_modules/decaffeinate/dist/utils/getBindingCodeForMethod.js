"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var IdentifierPatcher_1 = require("../stages/main/patchers/IdentifierPatcher");
function getBindingCodeForMethod(method) {
    var accessCode;
    if (method.key instanceof IdentifierPatcher_1.default) {
        accessCode = "." + method.key.node.data;
    }
    else {
        accessCode = "[" + method.key.getRepeatCode() + "]";
    }
    return "this" + accessCode + " = this" + accessCode + ".bind(this)";
}
exports.default = getBindingCodeForMethod;
