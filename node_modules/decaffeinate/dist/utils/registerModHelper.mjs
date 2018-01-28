var MOD_HELPER = "function __mod__(a, b) {\n  a = +a;\n  b = +b;\n  return (a % b + b) % b;\n}";
export default function registerModHelper(patcher) {
    return patcher.registerHelper('__mod__', MOD_HELPER);
}
