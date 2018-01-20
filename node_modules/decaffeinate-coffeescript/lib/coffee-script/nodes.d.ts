import Scope from './scope';
import { Token } from './lexer';

export type LocationData = {
  first_line: number,
  first_column: number,
  last_line: number,
  last_column: number,
};

export type CompileContext = {
  level?: number,
  indent?: string,
  scope?: Scope,
  sharedScope?: boolean,
};

/**
 * The various nodes defined below all compile to a collection of **CodeFragment** objects.
 * A CodeFragments is a block of generated code, and the location in the source file where the code
 * came from. CodeFragments can be assembled together into working code just by catting together
 * all the CodeFragments' `code` snippets, in order.
 */
export class CodeFragment {
  code: string;
  locationData: LocationData;
  type: string;

  constructor(parent: Base, code: string);
}

/**
 * The **Base** is the abstract base class for all nodes in the syntax tree.
 * Each subclass implements the `compileNode` method, which performs the
 * code generation for that node. To compile a node to JavaScript,
 * call `compile` on it, which wraps `compileNode` in some generic extra smarts,
 * to know when the generated code needs to be wrapped up in a closure.
 * An options hash is passed and cloned throughout, containing information about
 * the environment from higher in the tree (such as if a returned value is
 * being requested by the surrounding function), information about the current
 * scope, and indentation level.
 */
export class Base {
  locationData: LocationData;

  compile(o: CompileContext, lvl: number): string;

  /**
   * Common logic for determining whether to wrap this node in a closure before
   * compiling it, or to compile directly. We need to wrap if this node is a
   * *statement*, and it's not a *pureStatement*, and we're not at
   * the top level of a block (which would be unnecessary), and we haven't
   * already been asked to return the result (because statements know how to
   * return results).
   */
  compileToFragments(o: CompileContext, lvl: number): Array<CodeFragment>;

  /**
   * Statements converted into expressions via closure-wrapping share a scope
   * object with their parent closure, to preserve the expected lexical scope.
   */
  compileClosure(o: CompileContext): Array<CodeFragment>;

  /**
   * If the code generation wishes to use the result of a complex expression
   * in multiple places, ensure that the expression is only ever evaluated once,
   * by assigning it to a temporary variable. Pass a level to precompile.
   *
   * If `level` is passed, then returns `[val, ref]`, where `val` is the compiled value, and `ref`
   * is the compiled reference. If `level` is not passed, this returns `[val, ref]` where
   * the two values are raw nodes which have not been compiled.
   */
  cache(o: CompileContext, lvl: number, isComplex: boolean): [Base, Base] | [Array<CodeFragment>, Base];
  cacheToCodeFragments(cachedValues: [CodeFragment, CodeFragment]): Array<CodeFragment>;

  /**
   * Construct a node that returns the current node's result.
   * Note that this is overridden for smarter behavior for
   * many statement nodes (e.g. If, For)...
   */
  makeReturn(): Return;
  makeReturn(res: string): Call;

  /**
   * Does this node, or any of its children, contain a node of a certain kind?
   * Recursively traverses down the *children* nodes and returns the first one
   * that verifies `pred`. Otherwise return undefined. `contains` does not cross
   * scope boundaries.
   */
  contains(pred: (node: Base) => boolean): Base | undefined;

  /**
   * Pull out the last non-comment node of a node list.
   */
  lastNonComment<T extends Base>(list: Array<T>): T | null;

  /**
   * `toString` representation of the node, for inspecting the parse tree.
   * This is what `coffee --nodes` prints out.
   */
  toString(idt?: string, name?: string): string;

  /**
   * Passes each child to a function, breaking when the function returns `false`.
   */
  eachChild(func: (child: Base) => boolean | undefined): this;
  traverseChildren(crossScope: boolean, func: (child: Base) => boolean | undefined): this;
  inverted: boolean;
  invert(): Base;
  unwrapAll(): Base;

  /**
   * Default implementations of the common node properties and methods. Nodes
   * will override these with custom logic, if needed.
   */
  children: Array<string>;
  isStatement(o?: CompileContext): boolean;
  jumps(o?: CompileContext): boolean;
  isComplex(): boolean;
  isChainable(): boolean;
  isAssignable(): boolean;
  unwrap(): Base;
  unfoldSoak(): Base | null;

  /**
   * Is this node used to assign a certain variable?
   */
  assigns(name: string): boolean;

  /**
   * For this node and all descendents, set the location data to `locationData`
   * if the location data is not already set.
   */
  updateLocationDataIfMissing(locationData: LocationData): this;

  /**
   * Throw a SyntaxError associated with this node's location.
   */
  error(message: string): void;
  makeCode(code: string): CodeFragment;
  wrapInBraces(fragments: Array<CodeFragment>): Array<CodeFragment>;

  /**
   * `fragmentsList` is an array of arrays of fragments. Each array in fragmentsList will be
   * concatonated together, with `joinStr` added in between each, to produce a final flat array
   * of fragments.
   */
  joinFragmentArrays(fragmentsList: Array<Array<CodeFragment>>, joinStr: string): Array<CodeFragment>;
}

/**
 * The block is the list of expressions that forms the body of an
 * indented block of code -- the implementation of a function, a clause in an
 * `if`, `switch`, or `try`, and so on...
 */
export class Block extends Base {
  expressions: Array<Base>;
  classBody?: boolean;

  children: ['expressions']

  /**
   * Tack an expression on to the end of this expression list.
   */
  push(node: Base): this;

  /**
   * Remove and return the last expression of this expression list.
   */
  pop(): Base | null;

  /**
   * Add an expression at the beginning of this expression list.
   */
  unshift(node: Base): this;

  /**
   * If this Block consists of just a single node, unwrap it by pulling
   * it back out.
   */
  unwrap(): Base;

  /**
   * Is this an empty block of code?
   */
  isEmpty(): boolean;

  /**
   * A Block node does not return its entire body, rather it
   * ensures that the final expression is returned.
   */
  // makeReturn(res: string): Return

  /**
   * If we happen to be the top-level **Block**, wrap everything in
   * a safety closure, unless requested not to.
   * It would be better not to generate them in the first place, but for now,
   * clean up obvious double-parentheses.
   */
  compileRoot(o: CompileContext): Array<CodeFragment>;

  /**
   * Compile the expressions body for the contents of a function, with
   * declarations of all inner variables pushed up to the top.
   */
  compileWithDeclarations(o: CompileContext): Array<CodeFragment>;

  /**
   * Wrap up the given nodes as a **Block**, unless it already happens
   * to be one.
   */
  static wrap(nodes: Array<Base>): Block;

  constructor(nodes?: Array<Base>);
}

export class Literal extends Base {
  value: string;

  constructor(value: string);
}

export class Undefined extends Base {}
export class Null extends Base {}
export class Bool extends Base {
  val: string;

  constructor(val: string);
}

export class Return extends Base {
  expression?: Base;

  constructor(expression?: Base);
}

export class Value extends Base {
  base: Base;
  properties: Array<Access | Index | Slice>;

  constructor(base: Base, props: Array<Access | Index | Slice>, tag: string);

  /**
   * Add a property (or *properties* ) `Access` to the list.
   */
  add(props: Array<Access | Index | Slice>): this;
  hasProperties(): boolean;
  bareLiteral(type: typeof Base): boolean;

  /**
   * Some boolean checks for the benefit of other nodes.
   */
  isArray(): boolean;
  isRange(): boolean;
  isComplex(): boolean;
  isAssignable(): boolean;
  isSimpleNumber(): boolean;
  isString(): boolean;
  isRegex(): boolean;
  isAtomic(): boolean
  isNotCallable(): boolean
  isStatement(): boolean;
  assigns(): boolean;
  jumps(): boolean;
  isObject(onlyGenerated: boolean): boolean;
  isSplice(): boolean;
  looksStatic(className: string): boolean;

  /**
   * A reference has base part (`this` value) and name part.
   * We cache them separately for compiling complex expressions.
   * `a()[b()] ?= c` -> `(_base = a())[_name = b()] ? _base[_name] = c`
   */
  cacheReference(o: CompileContext): [Base, Base];
}

export class Comment extends Base {
  comment: string;

  constructor(comment: string);
}

/**
 * Node for a function invocation. Takes care of converting `super()` calls into
 * calls against the prototype's function of the same name.
 */
export class Call extends Base {
  isNew: boolean;
  isSuper: boolean;
  soak: boolean;
  do: boolean;
  variable: Base | null;
  args: Array<Base>;

  /**
   * Tag this invocation as creating a new instance.
   */
  newInstance(): Base;

  /**
   * Grab the reference to the superclass's implementation of the current
   * method.
   */
  superReference(o: CompileContext): string;

  /**
   * The appropriate `this` value for a `super` call.
   */
  superThis(o: CompileContext): string;

  /**
   * If you call a function with a splat, it's converted into a JavaScript
   * `.apply()` call to allow an array of arguments to be passed.
   * If it's a constructor, then things get real tricky. We have to inject an
   * inner constructor in order to be able to pass the varargs.
   *
   * splatArgs is an array of CodeFragments to put into the 'apply'.
   */
  compileSplat(o: CompileContext, splatArgs: Array<CodeFragment>): Array<CodeFragment>;
}


/**
 * Node to extend an object's prototype with an ancestor object.
 * After `goog.inherits` from the
 * [Closure Library](http://closure-library.googlecode.com/svn/docs/closureGoogBase.js.html).
 */
export class Extends extends Base {
  child: Base;
  parent: Base;

  constructor(child: Base, parent: Base);
}

/**
 * A `.` access into a property of a value, or the `::` shorthand for
 * an access into the object's prototype.
 */
export class Access extends Base {
  name: Base;
  soak: boolean;

  // TODO
}

 /**
  * A `[ ... ]` indexed access into an array or object.
  */
export class Index extends Base {
  index: Base;
  soak?: boolean;

  constructor(index: Base);
}

/**
 * A range literal. Ranges can be used to extract portions (slices) of arrays,
 * to specify a range for comprehensions, or as a value, to be expanded into the
 * corresponding array of integers at runtime.
 */
export class Range extends Base {
  from: Base | null;
  to: Base | null;
  exclusive: boolean;
  equals: boolean;

  /**
   * Compiles the range's source variables -- where it starts and where it ends.
   * But only if they need to be cached to avoid double evaluation.
   */
  compileVariables(o: CompileContext): void;
}

/**
 * An array slice literal. Unlike JavaScript's `Array#slice`, the second parameter
 * specifies the index of the end of the slice, just as the first parameter
 * is the index of the beginning.
 */
export class Slice extends Base {
  range: Range;
  soak?: boolean;

  constructor(range: Range);
}

/**
 * An object literal, nothing fancy.
 */
export class Obj extends Base {
  objects: Array<Base>;
  properties: Array<Base>;
  generated: boolean;
}

/**
 * An array literal.
 */
export class Arr extends Base {
  objects: Array<Base>;

  constructor(objs: Array<Base>);
}

/**
 * The CoffeeScript class definition.
 * Initialize a **Class** with its name, an optional superclass, and a
 * list of prototype property assignments.
 */
export class Class extends Base {
  variable?: Base;
  parent?: Base;
  body: Block;
  boundFuncs: Array<Code>;
  directives?: Array<Base>;
  ctor?: Code;

  /**
   * Figure out the appropriate name for the constructor function of this class.
   */
  determineName(): string;

  /**
   * For all `this`-references and bound functions in the class definition,
   * `this` is the Class being constructed.
   */
  setContext(name: string): void;

  /**
   * Ensure that all functions bound to the instance are proxied in the
   * constructor.
   */
  addBoundFunctions(o: CompileContext): void;

  /**
   * Merge the properties from a top-level object as prototypal properties
   * on the class.
   */
  addProperties(node: Base, name: string, o: CompileContext): Array<Base>;

  /**
   * Walk the body of the class, looking for prototype properties to be converted
   * and tagging static assignments.
   */
  walkBody(name: string, o: CompileContext): this;

  /**
   * `use strict` (and other directives) must be the first expression statement(s)
   * of a function body. This method ensures the prologue is correctly positioned
   * above the `constructor`.
   */
  hoistDirectivePrologue(): void;

  /**
   * Make sure that a constructor is defined for the class, and properly
   * configured.
   */
  ensureConstructor(name: string): void;
}

type AssignOptions = {
  param?: boolean;
  subpattern?: boolean;
  operatorToken?: Token;
};

/**
 * The **Assign** is used to assign a local variable to value, or to set the
 * property of an object -- including within object literals.
 */
export class Assign extends Base {
  variable: Base;
  value: Base;
  context?: string;
  param?: boolean;
  subpattern?: boolean;
  operatorToken?: Token;

  constructor(variable: Base, value: Base, context?: string, options?: AssignOptions);
}

/**
 * A function definition. This is the only node that creates a new Scope.
 * When for the purposes of walking the contents of a function body, the Code
 * has no *children* -- they're within the inner scope.
 */
export class Code extends Base {
  params: Array<Base>;
  body: Block;
  bound: boolean;
  isGenerator: boolean;

  constructor(params?: Array<Base>, body?: Block, tag?: string);

  makeScope(parentScope?: Scope): Scope;
}

/**
 * A parameter in a function definition. Beyond a typical Javascript parameter,
 * these parameters can also attach themselves to the context of the function,
 * as well as be a splat, gathering up a group of parameters into an array.
 */
export class Param extends Base {
  name: Base;
  value: Base | null;
  splat: boolean;

  constructor(name: Base, value: Base, splat: boolean);

  asReference(o: CompileContext): Base;
}

/**
 * A splat, either as a parameter to a function, an argument to a call,
 * or as part of a destructuring assignment.
 */
export class Splat extends Base {
  name: Base;

  constructor(name: Base | string);

  /**
   * Utility function that converts an arbitrary number of elements, mixed with
   * splats, to a proper array.
   */
  static compileSplattedArray(
    o: CompileContext, list: Array<Base>, apply: boolean): Array<CodeFragment>;
}

/**
 * Used to skip values inside an array destructuring (pattern matching) or
 * parameter list.
 */
export class Expansion extends Base {
  asReference(o: CompileContext): this;
}

/**
 * A while loop, the only sort of low-level loop exposed by CoffeeScript. From
 * it, all other loops can be manufactured. Useful in cases where you need more
 * flexibility or more speed than a comprehension can provide.
 */
export class While extends Base {
  condition: Base;
  guard?: Base;
  body?: Block;

  constructor(condition: Base, options?: { invert?: boolean, guard?: boolean });

  addBody(body: Base): this;
}

/**
 * Simple Arithmetic and logical operations. Performs some conversion from
 * CoffeeScript operations into their JavaScript equivalents.
 */
export class Op extends Base {
  operator: string;
  first: Base;
  second?: Base;
  flip: boolean;

  constructor(op: string, first: Base, second: Base, flip: boolean);

  isSimpleNumber(): boolean;
  isYield(): boolean;
  isYieldReturn(): boolean;
  isUnary(): boolean;
  isChainable(): boolean;

  /**
   * Mimic Python's chained comparisons when multiple comparison operators are
   * used sequentially. For example:
   *
   *     bin/coffee -e 'console.log 50 < 65 > 10'
   *     true
   */
  compileChain(o: CompileContext): Array<CodeFragment>;

  /**
   * Keep reference to the left expression, unless this an existential assignment
   */
  compileExistence(o: CompileContext): Array<CodeFragment>;

  /**
   * Compile a unary **Op**.
   */
  compileUnary(o: CompileContext): Array<CodeFragment>;
  compileYield(o: CompileContext): Array<CodeFragment>;
  compilePower(o: CompileContext): Array<CodeFragment>;
  compileFloorDivision(o: CompileContext): Array<CodeFragment>;
  compileModulo(o: CompileContext): Array<CodeFragment>;
}

export class In extends Base {
  object: Base;
  array: Base;

  constructor(object: Base, array: Base);

  compileOrTest(o: CompileContext): Array<CodeFragment>;
  compileLoopTest(o: CompileContext): Array<CodeFragment>;
}

/**
 * A classic *try/catch/finally* block.
 */
export class Try extends Base {
  attempt?: Block;
  errorVariable?: Base;
  recovery?: Block;
  ensure?: Block;

  constructor(attempt: Base, errorVariable?: Base, recovery?: Base, ensure?: Base);
}

/**
 * Simple node to throw an exception.
 */
export class Throw extends Base {
  expression: Base;

  constructor(expression: Base);
}

/**
 * Checks a variable for existence -- not *null* and not *undefined*. This is
 * similar to `.nil?` in Ruby, and avoids having to consult a JavaScript truth
 * table.
 */
export class Existence extends Base {
  expression: Base;

  constructor(expression: Base);
}

/**An extra set of parentheses, specified explicitly in the source. At one time
 * we tried to clean up the results by detecting and removing redundant
 * parentheses, but no longer -- you can put in as many as you please.
 *
 * Parentheses are a good way to force any statement to become an expression.
 */
export class Parens extends Base {
  body: Block;

  constructor(body: Block);
}

type ForOptions = {
  source: Base,
  guard?: Base,
  step?: Base,
  name?: Base,
  index?: Base,
};

/**
 * CoffeeScript's replacement for the *for* loop is our array and object
 * comprehensions, that compile into *for* loops here. They also act as an
 * expression, able to return the result of each filtered iteration.
 *
 * Unlike Python array comprehensions, they can be multi-line, and you can pass
 * the current index of the loop as a second parameter. Unlike Ruby blocks,
 * you can map and filter in a single pass.
 */
export class For extends While {
  range: boolean;
  body: Block;
  own: boolean;
  object: boolean;
  returns: boolean;
  name?: Base;
  index?: Base;
  source: Base;
  step?: Base;
  pattern: boolean;

  constructor(body: Base, source: ForOptions);
}

export type SwitchCaseCondition = Base | Array<Base>;

/**
 * A JavaScript *switch* statement. Converts into a returnable expression on-demand.
 */
export class Switch extends Base {
  subject: Base;
  cases: Array<[ SwitchCaseCondition, Block ]>;
  otherwise?: Block;

  constructor(subject: Base | null, cases: Array<[ SwitchCaseCondition, Block ]>, otherwise: Base);
}

/**
 * *If/else* statements. Acts as an expression by pushing down requested returns
 * to the last line of each clause.
 *
 * Single-expression **Ifs** are compiled into conditional operators if possible,
 * because ternaries are already proper expressions, and don't need conversion.
 */
export class If extends Base {
  condition: Base;
  body: Block;
  elseBody?: Block;
  isChain: boolean;
  soak: boolean;

  constructor(condition: Base, body: Block, options?: { soak: boolean });

  /**
   * Rewrite a chain of **Ifs** to add a default case as the final *else*.
   */
  addElse(elseBody: Block): this;

  /**
   * Compile the `If` as a regular *if-else* statement. Flattened chains
   * force inner *else* bodies into statement form.
   */
  compileStatement(o: CompileContext): Array<CodeFragment>;

  /**
   * Compile the `If` as a conditional operator.
   */
  compileExpression(o: CompileContext): Array<CodeFragment>;
}
