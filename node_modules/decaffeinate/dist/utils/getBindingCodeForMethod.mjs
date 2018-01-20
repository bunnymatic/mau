import IdentifierPatcher from '../stages/main/patchers/IdentifierPatcher';
export default function getBindingCodeForMethod(method) {
    var accessCode;
    if (method.key instanceof IdentifierPatcher) {
        accessCode = "." + method.key.node.data;
    }
    else {
        accessCode = "[" + method.key.getRepeatCode() + "]";
    }
    return "this" + accessCode + " = this" + accessCode + ".bind(this)";
}
