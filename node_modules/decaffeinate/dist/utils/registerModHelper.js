"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var MOD_HELPER = "function __mod__(a, b) {\n  a = +a;\n  b = +b;\n  return (a % b + b) % b;\n}";
function registerModHelper(patcher) {
    return patcher.registerHelper('__mod__', MOD_HELPER);
}
exports.default = registerModHelper;
