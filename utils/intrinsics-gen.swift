import Foundation
#if os(Linux)
  import Glibc
#else
  import Darwin
#endif

// Object ::=
enum Object {
  // Class |
  case classDecl(ClassDecl)
  // Def |
  case def(RecordDefinition)
  // Defm |
  case defm(RecordDefinition)
  // Let |
  case letDecl(Let)
  // MultiClass |
  case multiClassDecl(ClassDecl)
  // ForEach
  // case forEach(...)

  // TableGen has an include mechanism. It does not play a role in the syntax
  // per se, since it is lexically replaced with the contents of the included file.
  case include(Include)
}

// Class ::=  "class" TokIdentifier [TemplateArgList] ObjectBody
struct ClassDecl {
  struct TemplateArgument {
    let type: TDType
    let name: String
    let valueBinding: Optional<TDValue>

    init(_ type: TDType, _ name: String, _ valueBinding: Optional<TDValue>) {
      self.type = type
      self.name = name
      self.valueBinding = valueBinding
    }
  }

  // Name ::= TokIdentifier
  let name: String
  // TemplateArgList ::=  "<" Declaration ("," Declaration)* ">"
  let args: Array<TemplateArgument>
  // BaseClassList   ::=  [":" BaseClassListNE]
  let baseClassList: Array<TDType>
}

// Def ::=  "def" TokIdentifier ObjectBody
final class RecordDefinition {
  // Name ::= TokIdentifier
  let name: String
  // BaseClassList   ::=  [":" BaseClassListNE]
  var baseClassList: Array<TDType>

  init(name : String, baseClassList : Array<TDType>) {
    self.name = name
    self.baseClassList = baseClassList
  }
}

// Let     ::=   "let" LetList "in" "{" Object* "}"
//             | "let" LetList "in" Object
// LetList ::=  LetItem ("," LetItem)*
// LetItem ::=  TokIdentifier [RangeList] "=" Value
struct Let {
  // n.b. We currently don't care about the content of let-bindings.
  let objects: Array<Object>
}

// IncludeDirective ::=  "include" TokString
struct Include {
  let path: String
  let objects: Array<Object>
}

enum TDValue {
  case list(Array<TDValue>)
  case stringConcat(Array<TDValue>)
  case type(TDType)
  case string(String)
  case int(Int)
}

struct TDType {
  let name: String
  let args: Array<TDValue>
}

enum Token : Equatable, CustomDebugStringConvertible {
  case identifier(String)
  case int(Int)
  case string(String)
  case angles(Array<Token>)
  case squares(Array<Token>)
  case braces(Array<Token>)
  case parens(Array<Token>)
  case colon
  case comma
  case semicolon
  case equals
  case bang

  static func == (lhs: Token, rhs: Token) -> Bool {
    switch (lhs, rhs) {
    case let (.identifier(l), .identifier(r)):
      return l == r
    case let (.int(l), .int(r)):
      return l == r
    case let (.string(l), .string(r)):
      return l == r
    case let (.angles(l), .angles(r)):
      return l == r
    case let (.squares(l), .squares(r)):
      return l == r
    case let (.braces(l), .braces(r)):
      return l == r
    case let (.parens(l), .parens(r)):
      return l == r
    case (.colon, .colon):
      return true
    case (.comma, .comma):
      return true
    case (.semicolon, .semicolon):
      return true
    case (.equals, .equals):
      return true
    case (.bang, .bang):
      return true
    default:
      return false
    }
  }

  var debugDescription: String {
    switch self {
    case .colon:
      return " : "
    case .comma:
      return " , "
    case .semicolon:
      return " ; "
    case .equals:
      return " = "
    case .bang:
      return "!"
    case let .identifier(i):
      return i
    case let .int(i):
      return "\(i)"
    case let .string(s):
      return "\"\(s)\""
    case let .angles(toks):
      return "<" + toks.map({ $0.debugDescription }).joined(separator: ", ") + ">"
    case let .squares(toks):
      return "[" + toks.map({ $0.debugDescription }).joined(separator: ", ") + "]"
    case let .braces(toks):
      return "{" + toks.map({ $0.debugDescription }).joined(separator: ", ") + "}"
    case let .parens(toks):
      return "(" + toks.map({ $0.debugDescription }).joined(separator: ", ") + ")"
    }
  }
}

extension Character {
  var utf8CodePoint : CChar {
    return String(self).cString(using: .utf8)!.first!
  }

  fileprivate var isWhitespace : Bool {
    let utf8Value = self.utf8CodePoint
    return isspace(Int32(utf8Value)) != 0
  }
}

func tokenize(_ str: String, with lexRE: NSRegularExpression) -> Array<Token> {
  var stack = [[Token]]()
  var tokenStream = [Token]()
  var s = Substring(str)
  while !s.isEmpty && s.first!.isWhitespace {
    // will fail with non-ascii whitespace
    s = s.dropFirst()
  }

  while !s.isEmpty {
    let skipLength : Int;
    switch s.first! {
    case ":":
      tokenStream.append(.colon)
      skipLength = 1
    case ",":
      tokenStream.append(.comma)
      skipLength = 1
    case ";":
      tokenStream.append(.semicolon)
      skipLength = 1
    case "=":
      tokenStream.append(.equals)
      skipLength = 1
    case "!":
      tokenStream.append(.bang)
      skipLength = 1
    case "\"":
      guard let lexRE = try? NSRegularExpression(pattern: "^\"(.*?)\"") else {
        fatalError()
      }
      let strBuf = String(s)
      let string = lexRE.matches(in: strBuf, range: NSRange(location: 0, length: strBuf.utf8.count))[0]
      let r = string.range
      tokenStream.append(.string(String(strBuf[
        Range<String.Index>(
          uncheckedBounds: (
            strBuf.index(strBuf.startIndex, offsetBy: r.location),
            strBuf.index(strBuf.startIndex, offsetBy: NSMaxRange(r))
          )
        )
        ])))
      skipLength = NSMaxRange(r)
    case "0"..."9":
      guard let lexRE = try? NSRegularExpression(pattern: "^[0-9]+") else {
        fatalError()
      }
      let strBuf = String(s)
      let string = lexRE.matches(in: strBuf, range: NSRange(location: 0, length: strBuf.utf8.count))[0]
      let r = string.range
      tokenStream.append(Token.int(Int(String(strBuf[
        Range<String.Index>(
          uncheckedBounds: (
            strBuf.index(strBuf.startIndex, offsetBy: r.location),
            strBuf.index(strBuf.startIndex, offsetBy: NSMaxRange(r))
          )
        )
        ]))!))
      skipLength = NSMaxRange(r)
    case "<": fallthrough
    case "(": fallthrough
    case "{": fallthrough
    case "[":
      stack.append(tokenStream)
      tokenStream.removeAll()
      skipLength = 1
    case ">":
      let tok = Token.angles(tokenStream)
      tokenStream = stack.popLast()! + [tok]
      skipLength = 1
    case "}":
      let tok = Token.braces(tokenStream)
      tokenStream = stack.popLast()! + [tok]
      skipLength = 1
    case "]":
      let tok = Token.squares(tokenStream)
      tokenStream = stack.popLast()! + [tok]
      skipLength = 1
    case ")":
      let tok = Token.parens(tokenStream)
      tokenStream = stack.popLast()! + [tok]
      skipLength = 1
    // comment
    case "/":
      skipLength = s.split(whereSeparator: { c in c == "\n" }).first!.utf8.count
    case let c where c.isWhitespace:
      skipLength = 0
    default:
      let strBuf = String(s)
      let string = lexRE.matches(in: strBuf, range: NSRange(location: 0, length: strBuf.utf8.count))[0]
      let r = string.range
      tokenStream.append(Token.identifier(String(strBuf[
        Range<String.Index>(
          uncheckedBounds: (
            strBuf.index(strBuf.startIndex, offsetBy: r.location),
            strBuf.index(strBuf.startIndex, offsetBy: NSMaxRange(r))
          )
        )
        ])))
      skipLength = NSMaxRange(r)
    }

    s = s.dropFirst(skipLength)
    while !s.isEmpty && s.first!.isWhitespace {
      // will fail with non-ascii whitespace
      s = s.dropFirst()
    }
  }

  assert(stack.isEmpty)
  return tokenStream
}


func extractDefinitions(_ items: Array<Object>) -> (classes: Array<ClassDecl>, records: Array<RecordDefinition>) {
  var classes = [ClassDecl]()
  var defs = [RecordDefinition]()
  for it in items {
    switch it {
    case let .letDecl(letStream):
      let defns = extractDefinitions(letStream.objects)
      classes.append(contentsOf: defns.classes)
      defs.append(contentsOf: defns.records)
    case let .include(includeStream):
      let defns = extractDefinitions(includeStream.objects)
      classes.append(contentsOf: defns.classes)
      defs.append(contentsOf: defns.records)
    case let .classDecl(c):
      classes.append(c)
    case let .def(d):
      defs.append(d)
    // Ignore multiclasses and multidefs for now.
    case .defm(_), .multiClassDecl(_): break
    }
  }
  return (classes, defs)
}

func resolveClasses(_ defs: [RecordDefinition], _ classes: Dictionary<String, ClassDecl>) {
  func performTypeSubstitution(_ types: inout Array<TDType>, _ ty: TDType, _ classes: Dictionary<String, ClassDecl>,
                               _ args: Dictionary<String, TDValue>) {
    guard let resolvedClass : ClassDecl = classes[ty.name] else {
      types.append(ty)
      return
    }

    let tyArgs = ty.args.map(Optional.some)
    let argSeq : UnfoldSequence<Optional<TDValue>, (Optional<TDValue>?, Bool)>
    if tyArgs.isEmpty {
      argSeq = sequence(first: nil, next: { _ in nil })
    } else {
      var idx = 1
      argSeq = sequence(first: tyArgs[0], next: { _ in
        defer { idx += 1 }
        if idx < tyArgs.count {
          return tyArgs[idx]
        }
        return .some(Optional<TDValue>.none)
      })
    }

    let boundArgs = zip(argSeq, resolvedClass.args).map({ (t) -> TDValue in
      let (left, right) = t
      return left.map({ v in substitute(v, args) }) ?? right.valueBinding!
    })

    let arg_dict = zip(boundArgs, resolvedClass.args).map({ (t) -> (String, TDValue) in
      let (val, right) = t
      return (right.name, val)
    })

    for superClass in resolvedClass.baseClassList {
      performTypeSubstitution(&types, superClass, classes, Dictionary(uniqueKeysWithValues: arg_dict))
    }

    types.append(TDType(name: ty.name, args: boundArgs))
  }

  func substitute(_ val: TDValue, _ rules: Dictionary<String, TDValue>) -> TDValue {
    switch val {
    case .type(let ty):
      switch rules[ty.name] {
      case let .some(new):
        assert(ty.args.isEmpty)
        return new
      case .none: return val
      }

    case .list(let vals):
      return TDValue.list(vals.map({ v in substitute(v, rules) }))

    case .stringConcat(let vals):
      let new = vals.map({ v in substitute(v, rules) })
      if new.reduce(true, { (acc, s) in
        switch s {
        case .string(_): return true && acc
        default: return false
        }
      }) {
        return TDValue.string(new.map({ (s) -> String in
          switch s {
          case .string(let s):
            return s
          default:
            fatalError()
          }
        }).joined())
      } else {
        return .stringConcat(new)
      }

    default:
      return val
    }
  }

  for d in defs {
    let empty = Dictionary<String, TDValue>()
    var substituteList = [TDType]()
    for sup in d.baseClassList {
      performTypeSubstitution(&substituteList, sup, classes, empty)
    }
    d.baseClassList = substituteList
  }
}

struct Parser<S: IteratorProtocol> where S.Element == Token {
  var tokens: S
  let root: String


  func subparser<T: IteratorProtocol>(_ iter: T) -> Parser<T>
    where T.Element == Token
  {
    return Parser<T>(
      tokens: iter,
      root: self.root
    )
  }


  mutating func parseTableGen() -> Array<Object> {
    var ret = [Object]()
    while let item = self.maybeParseObject() {
      ret.append(item)
    }
    return ret
  }

  mutating func maybeParseObject() -> Optional<Object> {
    return self.maybeParseIdentifier().map({ (ident) -> Object in
      switch ident {
      case "class":
        return Object.classDecl(self.parseClass())
      case "def":
        return Object.def(self.parseRecordDefinition())
      case "defm":
        return Object.defm(self.parseRecordDefinition())
      case "let":
        return Object.letDecl(self.parseLet())
      case "multiclass":
        return Object.multiClassDecl(self.parseClass())
      case "include":
        return Object.include(self.parseInclude())
      default:
        fatalError("unexpected keyword \(ident)")
      }
    })
  }

  mutating func consumeToken() -> Token {
    return self.tokens.next()!
  }

  mutating func consume(_ expected: Token) {
    expect(self.consumeToken(), expected)
  }

  mutating func maybeParseIdentifier() -> Optional<String> {
    return self.tokens.next().map(expectIdentifier)
  }

  mutating func parseIdentifier() -> String {
    guard let ident = self.maybeParseIdentifier() else {
      fatalError("Unexpected EOF while parsing identifier")
    }
    return ident
  }

  mutating func parseClass() -> ClassDecl {
    let name = self.parseIdentifier()

    let (args, tok) = { () -> (Array<ClassDecl.TemplateArgument>, Token) in
      switch self.consumeToken() {
      case let Token.angles(contents):
        var args = Array<ClassDecl.TemplateArgument>()
        var subparser = self.subparser(contents.makeIterator())
        while let (ty, tok) = subparser.maybeParseType(nil) {
          let name = expectIdentifier(tok ?? subparser.consumeToken())
          let (next, val) = { () -> (Token?, TDValue?) in
            switch subparser.tokens.next() {
            case .some(Token.equals):
              let (val, tok) = subparser.maybeParseValueBinding()!
              return (tok ?? subparser.tokens.next(), .some(val))
            case let tok:
              return (tok, nil)
            }
          }()

          args.append(ClassDecl.TemplateArgument(ty, name, val))
          switch next {
          case let .some(tok):
            expect(tok, .comma)
          case .none:
            break
          }
        }
        return (args, self.consumeToken())
      case let tok:
        return ([], tok)
      }
    }()

    let parsedInhClause = { () -> Array<TDType> in
      switch tok {
      case Token.semicolon, Token.braces(_):
        return []
      case Token.colon:
        return self.parseInheritanceClause()
      case let tok:
        fatalError("while parsing inheritance list, expected : or {{...}}, found \(tok)")
      }
    }()
    return ClassDecl(name: name, args: args, baseClassList: parsedInhClause)
  }

  mutating func parseRecordDefinition() -> RecordDefinition {
    let name = self.parseIdentifier()
    self.consume(.colon)
    let inherits = self.parseInheritanceClause()
    return RecordDefinition(name: name, baseClassList: inherits)
  }

  mutating func parseLet() -> Let {
    _ = self.parseIdentifier()
    self.consume(Token.equals)
    switch self.consumeToken() {
    case Token.squares(_), Token.string(_), Token.int(_):
      break
    case let tok:
      fatalError("while parsing let binding, expected [...], string or int, found \(tok)")
    }
    self.consume(Token.identifier("in"))
    switch self.consumeToken() {
    case let Token.braces(contents):
      var subparser = self.subparser(contents.makeIterator())
      let items = subparser.parseTableGen()
      return Let(objects: items)
    case let tok:
      fatalError("expected {{...}}, found \(tok)")
    }
  }

  mutating func parseInclude() -> Include {
    guard case let Token.string(path) = self.consumeToken() else {
      fatalError("expected string")
    }

    // ignore includes for now
    return Include(path: path, objects: [])
  }

  mutating func parseInheritanceClause() -> Array<TDType> {
    var ret = Array<TDType>()

    var shouldBreak = false
    repeat {
      let (ty, tok) = self.maybeParseType(.none)!
      ret.append(ty)

      switch tok ?? self.consumeToken() {
      case Token.comma: break

      case Token.semicolon, Token.braces(_):
        shouldBreak = true
      case let tok:
        fatalError("while parsing inheritance clause, expected ','  or {{...}}, found \(tok)")
      }
    } while (!shouldBreak)
    return ret
  }

  mutating func maybeParseType(_ first: Optional<Token>) -> Optional<(TDType, Optional<Token>)> {
    return (first.map(expectIdentifier) ?? self.maybeParseIdentifier()).map({ name in
      switch self.tokens.next() {
      case let .some(Token.angles(contents)):
        var subparser = self.subparser(contents.makeIterator())
        let vals = subparser.parseValueList()
        return (TDType(
          name: name,
          args: vals
        ), nil)
      case let tok:
        return (TDType(name: name, args: []), tok)
      }
    })
  }

  mutating func parseValueList() -> Array<TDValue> {
    var ret = Array<TDValue>()
    while let (val, tok) = self.maybeParseValueBinding() {
      ret.append(val)

      guard let tol = tok ?? self.tokens.next() else {
        break
      }
      expect(tol, .comma)
    }
    return ret
  }

  mutating func maybeParseValueBinding() -> Optional<(TDValue, Optional<Token>)> {
    return self.tokens.next().map({ tok in
      switch tok {
      case let Token.int(n):
        return (TDValue.int(n), nil)
      case let Token.string(s):
        return (TDValue.string(s), nil)
      case let Token.squares(contents):
        var subparser = self.subparser(contents.makeIterator())
        let vals = subparser.parseValueList()
        return (TDValue.list(vals), nil)
      case Token.bang:
        self.consume(Token.identifier("strconcat"))
        switch self.consumeToken() {
        case let Token.parens(contents):
          var subparser = self.subparser(contents.makeIterator())
          let vals = subparser.parseValueList()
          return (TDValue.stringConcat(vals), nil)
        case let tok:
          fatalError("expected (...), found \(tok)")
        }
      default:
        let (ty, tyTok) = self.maybeParseType(.some(tok))!
        return (TDValue.type(ty), tyTok)
      }
    })
  }

  private func expect(_ t: Token, _ expected: Token) {
    if t != expected {
      fatalError("Unexpected token encountered: expected \(expected), found \(t)")
    }
  }

  private func expectIdentifier(_ tok: Token) -> String {
    switch tok {
    case let .identifier(s): return s
    default: fatalError("expected ident, found \(tok)")
    }
  }
}

indirect enum LLVMType : Equatable {
  enum MatchStyle {
    case direct, extend, truncate, sameWidth, pointersToElem, pointerToElt
  }

  case void
  case any
  case int(Optional<Int>)
  case float(Optional<Int>)
  case fixedPoint(Int)
  case pointer(Optional<LLVMType>)

  case vector(Optional<(Int, LLVMType)>)
  case metadata
  case token
  case vararg
  case descriptor
  case x86MMX
  case mips(LLVMType)

  case matchType(Int, MatchStyle)
  case matchedType(Int, LLVMType)

  static func sizedInt(_ x: Int) -> LLVMType { return LLVMType.int(.some(x)) }
  static func sizedFloat(_ x: Int) -> LLVMType { return LLVMType.float(.some(x)) }
  static func anyPtr(_ ty: LLVMType) -> LLVMType { return LLVMType.pointer(.some(ty)) }

  var llvmName : String {
    switch self {
    case let .int(.some(w)):
      return "i\(w)"
    case let .float(.some(w)):
      return "f\(w)"
    case let .pointer(.some(w)):
      return "p0\(w.llvmName)"
    case let .vector(.some(w, ty)) where w != -1:
      return "v\(w)\(ty.llvmName)"
    case .matchedType(_, _),
         .vector(_),
         .metadata,
         .vararg,
         .token,
         .descriptor,
         .any,
         .void:
      return ""
    default:
      fatalError()
    }
  }

  static func == (lhs : LLVMType, rhs : LLVMType) -> Bool {
    switch (lhs, rhs) {
    case (.void, .void): return true
    case (.any, .any): return true
    case let (.int(l), .int(r)): return l == r
    case let (.float(l), .float(r)): return l == r
    case let (.fixedPoint(l), .fixedPoint(r)): return l == r
    case let (.pointer(l), .pointer(r)): return l == r
    case let (.vector(.some(lw, lt)), .vector(.some(rw, rt))): return lw == rw && lt == rt
    case (.vector(.none), .vector(.none)): return true
    case (.metadata, .metadata): return true
    case (.token, .token): return true
    case (.vararg, .vararg): return true
    case (.descriptor, .descriptor): return true
    case (.x86MMX, .x86MMX): return true
    case let (.mips(l), .mips(r)): return l == r
    case let (.matchType(l, s1), .matchType(r, s2)): return l == r && s1 == s2
    case let (.matchedType(l, _), .matchedType(r, _)): return l == r
    default: return false
    }
  }
}

extension Character {
  fileprivate var isDigit : Bool {
    let utf8Value = self.utf8CodePoint
    return isdigit(Int32(utf8Value)) != 0
  }
}

func internalizeType(_ s: String) -> Optional<LLVMType> {
  switch s {
  case "float": return .some(LLVMType.sizedFloat(32))
  case "double": return .some(LLVMType.sizedFloat(64))
  case "anyvector": return .some(LLVMType.vector(.none))
  case "anyfloat": return .some(LLVMType.float(.none))
  case "anyint": return .some(LLVMType.int(.none))
  case "anyptr": return .some(LLVMType.pointer(.none))
  case "any": return .some(LLVMType.any)
  case "ptr": return .some(LLVMType.anyPtr(.sizedInt(8)))
  case "ptrptr": return .some(LLVMType.anyPtr(.anyPtr(.sizedInt(8))))
  case "anyi64ptr": return .some(LLVMType.anyPtr(.sizedInt(64)))
  case "metadata": return .some(LLVMType.metadata)
  case "token": return .some(LLVMType.token)
  case "vararg": return .some(LLVMType.vararg)
  case "descriptor": return .some(LLVMType.descriptor)
  case "x86mmx": return .some(LLVMType.x86MMX)
  case "ptrx86mmx": return .some(LLVMType.anyPtr(.x86MMX))
  default: break
  }
  if s.hasPrefix("i") {
    return Int(String(s.dropFirst())).map(LLVMType.sizedInt)
  } else if s.hasPrefix("f") {
    return Int(String(s.dropFirst())).map(LLVMType.sizedFloat)
  } else if s.hasPrefix("q") {
    return Int(String(s.dropFirst())).map(LLVMType.fixedPoint)
  } else if s.hasPrefix("v") {
    let vecLen = 1 + s.dropFirst().split(whereSeparator: { d in !d.isDigit }).first!.count
    return Int(s[s.index(after: s.startIndex)...s.index(s.startIndex, offsetBy: vecLen)]).map({ n in
      return internalizeType(String(s[s.index(s.startIndex, offsetBy: vecLen)...])).map({ t in LLVMType.vector(.some((n, t))) })
    })!
  } else {
    print("while internalizing types, encountered undefined type name: \(s)");
    return nil
  }
}

extension LLVMType {
  init?(interning s: String) {
    let str: String
    if s.hasPrefix("mips_") && s.hasSuffix("_ty") {
      str = String(s[s.index(s.startIndex, offsetBy: "mips_".count)..<s.index(s.startIndex, offsetBy: s.count - "_ty".count)])
    } else {
      str = String(s[s.index(s.startIndex, offsetBy: "llvm_".count)..<s.index(s.startIndex, offsetBy: s.count - "_ty".count)])
    }

    guard let internTy = internalizeType(str) ?? internalizeType(s) else {
      return nil
    }
    self = internTy
  }
}

extension LLVMType {
  init?(_ t: TDType) {
    guard !t.args.isEmpty else {
      guard let ty = LLVMType(interning: t.name) else {
        return nil
      }
      self = ty
      return
    }

    if t.name == "LLVMAnyPointerType", case let TDValue.type(t) = t.args[0] {
      guard let anyPtrTy = LLVMType(t).map(LLVMType.anyPtr) else {
        return nil
      }
      self = anyPtrTy
      return
    }

    if t.name == "LLVMVectorSameWidth", case let TDValue.type(t) = t.args[1] {
      guard let sameVecTy = LLVMType(t).map({LLVMType.vector(.some((-1, $0)))}) else {
        return nil
      }
      self = sameVecTy
      return
    }

    let styleo = { () -> MatchStyle? in
      switch t.name {
      case "LLVMMatchType":
        return MatchStyle.direct
      case "LLVMExtendedType":
        return MatchStyle.extend
      case "LLVMTruncatedType":
        return MatchStyle.truncate
      case "LLVMVectorOfPointersToElt", "LLVMVectorOfAnyPointersToElt":
        return MatchStyle.pointersToElem
      case "LLVMPointerToElt":
        return MatchStyle.pointerToElt
      default:
        return nil
      }
    }()

    let n = { () -> Int? in
      switch t.args[0] {
      case let TDValue.int(n): return n
      default: return nil
      }
    }()

    guard let m = n, let style = styleo else {
      return nil
    }

    self = LLVMType.matchType(m, style)
  }
}

enum Arch : String {
  case Global = "Global"

  case AMDGPU = "AMDGPU"
  case Aarch64 = "aarch64"
  case Arm = "arm"
  case Cuda = "cuda"
  case Hexagon = "hexagon"
  case Mips = "mips"
  case Nvvm = "nvvm"
  case Ppc = "ppc"
  case Ptx = "ptx"
  case R600 = "r600"
  case X86 = "x86"
  case Xcore = "xcore"
}

struct Intrinsic {
  enum Stop : Error { case iter }

  let arch: Arch
  let name: String
  let gccName: Optional<String>
  let llvmName: Optional<String>
  let parameterTypes: Array<LLVMType>
  let returnTypes: Array<LLVMType>


  static func fromAST(_ d: RecordDefinition, with lexRE: NSRegularExpression) -> Optional<Intrinsic> {
    if !d.name.hasPrefix("int_") { return nil }
    let strBuf = d.name
    let string = lexRE.matches(in: strBuf, range: NSRange(location: 0, length: strBuf.utf8.count))[0]
    let r = string.range
    let arch = Arch(rawValue: String(strBuf[
      Range<String.Index>(
        uncheckedBounds: (
          strBuf.index(strBuf.startIndex, offsetBy: r.location),
          strBuf.index(strBuf.startIndex, offsetBy: NSMaxRange(r))
        )
    )]))

    var gcc_name : String? = nil;
    var llvm_name : String? = nil;
    var params: Array<LLVMType> = [LLVMType]()
    var rets: Array<LLVMType> = [LLVMType]()
    for sup in d.baseClassList {
      switch sup.name {
      case "GCCBuiltin":
        switch sup.args[0] {
        case TDValue.string(let s):
          if !s.isEmpty {
            gcc_name = .some(s)
          }
        default:
          return nil
        }

      case "Intrinsic":
        switch sup.args[0] {
        case TDValue.list(let ret_):
          rets = (try? ret_.map({ v in
            switch v {
            case TDValue.type(let t):
              guard let lt = LLVMType(t) else {
                throw Stop.iter
              }
              return lt
            default:
              throw Stop.iter
            }
          })) ?? []
        default:
          return nil
        }

        switch sup.args[1] {
        case TDValue.list(let params_):
          params = (try? params_.map({ v in
            switch v {
            case TDValue.type(let t):
              guard let lt = LLVMType(t) else {
                _ = LLVMType(t)
                throw Stop.iter
              }
              return lt
            default:
              throw Stop.iter
            }
          })) ?? []
        default:
          return nil
        }

        switch sup.args[3] {
        case TDValue.string(let s):
          if !s.isEmpty {
            llvm_name = .some(s)
          }
        default:
          return nil
        }

      default:
        continue
      }
    }

    return .some(Intrinsic(
      arch: arch ?? Arch.Global,
      name: d.name,
      gccName: gcc_name,
      llvmName: llvm_name,
      parameterTypes: params,
      returnTypes: rets.isEmpty ? [LLVMType.void] : rets
    ))
  }
}

extension Intrinsic {
  func signatures() -> [(String, [LLVMType], LLVMType)] {
    var sigs = [(String, [LLVMType], LLVMType)]()
    let tys = self.returnTypes + self.parameterTypes

    func permute(_ ty : LLVMType) -> [LLVMType] {
      switch ty {
      case .pointer(.none):
        return [.pointer(.some(.int(8)))]
      case let .pointer(.some(i)):
        return permute(i).map({ LLVMType.pointer(.some($0)) })
      case .int(.none):
        return [.sizedInt(8), .sizedInt(16), .sizedInt(32), .sizedInt(64)]
      case let .int(.some(w)):
        return [.int(w)]
      case .float(.none):
        return [.sizedFloat(16), .sizedFloat(32), .sizedFloat(64), .sizedFloat(80), .sizedFloat(128)]
      case let .float(.some(w)):
        return [.float(w)]
      case .void:
        return [.void]
      case .metadata:
        return [.metadata]
      case .vararg:
        return [.vararg]
      case .token:
        return [.token]
      case .descriptor:
        return [.descriptor]
      case .any:
        return [.any]
      case let .matchType(n, .pointerToElt):
        return [.matchedType(n, LLVMType.anyPtr(tys[n]))]
      case let .matchType(n, .pointersToElem):
        return [.matchedType(n, LLVMType.vector(.some((-1, LLVMType.anyPtr(tys[n])))))]
      case let .matchType(n, _):
        return [.matchedType(n, tys[n])]
        // N.B. Do not expand the overload set here.  There are simply too many
      // permutations to cover.  Dynamically generate these instead.
      case .vector(_):
        return [ty]
      default:
        fatalError()
      }
    }

    let baseName : String
    if let lName = self.llvmName?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")), !lName.isEmpty {
      baseName = lName
    } else if self.name == "int_ssa_copy" {
      // HACK: int_ssa_copy is missing its LLVM Name and bucks the naming
      // convention by having the proper name "llvm.ssa_copy".
      baseName = "llvm." + String(self.name.dropFirst("int_".count))
    } else {
      baseName = "llvm." + String(self.name.dropFirst("int_".count)).replacingOccurrences(of: "_", with: ".")
    }

    let sigMatrix = tys.map(permute)

    guard sigMatrix.reduce(false, { (acc, arr) in
      return acc || arr.count > 1
    }) else {
      let retTy = sigMatrix.first!.first!
      let paramTys = [LLVMType](sigMatrix.dropFirst().joined())
      return [(baseName, paramTys, retTy)]
    }

    var overloadMatrix = [[LLVMType]]()
    var sawOverload = false
    for i in 0..<sigMatrix.count {
      let parameters = sigMatrix[i]
      assert(!parameters.isEmpty)

      // If we're out of overloads to process next, drop it.  The signature
      // extends only as far as the first overloaded parameter.
      if sawOverload && parameters.count < 2 {
        break
      }

      guard parameters.count > 1 else {
        // If the transposed matrix is empty, stick the first parameter in.
        guard !overloadMatrix.isEmpty else {
          overloadMatrix.append([parameters[0]])
          continue
        }

        // Just append the parameter
        for j in 0..<overloadMatrix.count {
          overloadMatrix[j].append(parameters[0])
        }

        continue
      }

      // Only stop permuting if we encounter an overloaded parameter.
      sawOverload = (i != 0)

      guard !overloadMatrix.isEmpty else {
        for p in parameters {
          overloadMatrix.append([p])
        }
        continue
      }

      let matrixCpy = overloadMatrix
      for _ in 1..<parameters.count {
        overloadMatrix.append(contentsOf: matrixCpy)
      }

      assert(overloadMatrix.count % parameters.count == 0)
      for j in 0..<overloadMatrix.count {
        let paramOverload = parameters[j % parameters.count]
        overloadMatrix[j].append(paramOverload)
      }
    }

    // Verify all the overloads recieved the same number of parameters.
    assert({
      let checkCnt = overloadMatrix[0].count
      return overloadMatrix.reduce(true) { (acc, arr) in acc && arr.count == checkCnt }
    }())

    var seenSelectors = Set<String>()
    for initialList in overloadMatrix {
      // Re-process matched types.
      let paramList = initialList.map { (p) -> LLVMType in
        if case let .matchedType(n, _) = p {
          return LLVMType.matchedType(n, initialList[n])
        }
        return p
      }
      let retTy = paramList.first!
      let selector = ([baseName] + paramList.compactMap({ $0.llvmName.isEmpty ? nil : $0.llvmName })).joined(separator: ".")
      guard seenSelectors.insert(selector).inserted else {
        continue
      }
      sigs.append((selector, [LLVMType](paramList.dropFirst()), retTy))
    }

    return sigs
  }
}

func parse(s: String, root: String) -> Array<Object> {
  guard let lexRE = try? NSRegularExpression(pattern: "[A-Za-z0-9_]+") else {
    fatalError()
  }
  var p = Parser(
    tokens: tokenize(s, with: lexRE).makeIterator(),
    root: root
  )
  return p.parseTableGen()
}

func formFunctionTypeString(_ params: [LLVMType], _ retTy: LLVMType) -> String {
  func translateAType(_ ty : LLVMType) -> String {
    switch ty {
    case .float(.some(16)):
      return "FloatType.half"
    case .float(.some(32)):
      return "FloatType.float"
    case .float(.some(64)):
      return "FloatType.double"
    case .float(.some(80)):
      return "FloatType.x86FP80"
    case .float(.some(128)):
      return "FloatType.ppcFP128"
    case .int(.some(let w)):
      return "IntType(width: \(w))"
    case .x86MMX:
      return "X86MMXType()"
    case .matchedType(_, let ty):
      return translateAType(ty)
    case .pointer(.some(let ty)):
      return "PointerType(pointee: \(translateAType(ty)))"
    case .pointer(.none):
      return "PointerType(pointee: IntType.int8)"
    case .vector(.none):
      return "VectorType(elementType: IntrinsicSubstitutionMarker(), count: -1)"
    case .vector(.some(let size, let ty)) where size == -1:
      return "VectorType(elementType: \(translateAType(ty)), count: -1)"
    case .vector(.some(let size, let ty)):
      return "VectorType(elementType: \(translateAType(ty)), count: \(size))"
    case .metadata:
      return "MetadataType()"
    case .token:
      return "TokenType()"
    case .void:
      return "VoidType()"
    case .descriptor:
      return "PointerType(pointee: StructType(elementTypes: []))"
    case .any:
      return "IntrinsicSubstitutionMarker()"
    case .vararg:
      return ""
    default:
      fatalError("\(ty)")
    }
  }
  let paramTys = params.map(translateAType)
  let paramTyStr : String
  let isVariadic : String
  if let last = paramTys.last, last.isEmpty {
    paramTyStr = paramTys.dropLast().joined(separator: ", ")
    isVariadic = "true"
  } else {
    paramTyStr = paramTys.joined(separator: ", ")
    isVariadic = "false"
  }
  let retTyStr = translateAType(retTy)
  return "FunctionType(argTypes: [\(paramTyStr)], returnType: \(retTyStr), isVarArg: \(isVariadic))"
}

func run() {
  guard CommandLine.arguments.count > 1 else {
    print("usage: intrinsics-gen td-file ...")
    return
  }

  let args = CommandLine.arguments.dropFirst()
  guard args.reduce(true, { (acc, s) in s.hasSuffix(".td") && acc }) else {
    print("fatal: all arguments must be '.td' files")
    return
  }

  let fileUrls = args.compactMap(URL.init(fileURLWithPath:))
  guard fileUrls.count == args.count else {
    print("fatal: unable to locate all td files: \(args.joined(separator: ", "))")
    return
  }

  var intrinsicMap = Dictionary<Arch, [Intrinsic]>();
  for url in fileUrls {
    guard let s = try? String(contentsOf: url, encoding: .utf8) else {
      print("fatal: unable to read file at path: \(url.absoluteString)")
      return
    }

    let ast = parse(s: s, root: "")
    let (classes, defs) = extractDefinitions(ast)

    var classNames = Dictionary<String, ClassDecl>()
    for c in classes {
      guard classNames.updateValue(c, forKey: c.name) == nil else {
        print("fatal: multiple definitions of class '\(c.name)' found")
        return
      }
    }

    resolveClasses(defs, classNames)

    guard let lexRE = try? NSRegularExpression(pattern: "^int_([^_]*)") else {
      fatalError()
    }

    for d in defs {
      let intr : Intrinsic
      switch Intrinsic.fromAST(d, with: lexRE) {
      case .none where !d.name.hasPrefix("int_"):
        continue
      case .none:
        fatalError("failed to parse: \(d)")
      case let .some(intr2):
        intr = intr2
      }

      if intrinsicMap[intr.arch] != nil {
        intrinsicMap[intr.arch]!.append(intr)
      } else {
        intrinsicMap[intr.arch] = [intr]
      }
    }
  }

  var fileStructure = [String]()
  fileStructure.append("""
  // THIS FILE IS PROGRAMMATICALLY GENERATED!
  // DO NOT EDIT IT BY HAND!
  //
  // ALWAYS RUN intrinsics-gen AGAINST THE LATEST Intrinsics.td

  import LLVM

  """)
  for (arch, instrs) in intrinsicMap {
    print("Dumping arch: '\(arch)Intrinsics'...")
    var enums = [String]()
    var singularCaseMap = [(String, String)]()
    fileStructure.append("public enum \(arch.rawValue)Intrinsics: String, LLVMIntrinsic {")
    for intr in instrs {
      let sigs = intr.signatures()
      assert(!sigs.isEmpty)

      if sigs.count != 1 {
        var enumStr = "  public enum \(intr.name): String, LLVMOverloadedIntrinsic {"
        var caseMap = [(String, String)]()
        for (c, ps, rs) in sigs {
          let caseName = c.replacingOccurrences(of: ".", with: "_")
          caseMap.append((caseName, formFunctionTypeString(ps, rs)))
          enumStr.append("\n    case \(caseName) = \"\(c)\"")
        }

        enumStr.append("\n\n    public var llvmSelector: String { return self.rawValue }")
        enumStr.append("\n\n    public var signature: FunctionType {")
        enumStr.append("\n      switch self {")
        for (caseName, fnTyStr) in caseMap {
          enumStr.append("\n      case .\(caseName): return \(fnTyStr)")
        }
        enumStr.append("\n      }")
        enumStr.append("\n    }")
        enumStr.append("\n\n    public static var overloadSet: [LLVMIntrinsic] {")
        enumStr.append("\n      return [")
        for (caseName, _) in caseMap {
          enumStr.append("\n        \(intr.name).\(caseName),")
        }
        enumStr.append("\n      ]")
        enumStr.append("\n    }")

        enumStr.append("\n  }\n")

        enums.append(enumStr)
      } else {
        let caseName = sigs[0].0.replacingOccurrences(of: ".", with: "_")
        singularCaseMap.append((caseName, formFunctionTypeString(sigs[0].1, sigs[0].2)))
        fileStructure.append("\n  case \(caseName) = \"\(sigs[0].0)\"")
      }
    }

    fileStructure.append("\n\n  public var llvmSelector: String { return self.rawValue }")
    fileStructure.append("\n\n  public var signature: FunctionType {")
    fileStructure.append("\n    switch self {")
    for (caseName, fnTyStr) in singularCaseMap {
      fileStructure.append("\n    case .\(caseName): return \(fnTyStr)")
    }
    fileStructure.append("\n    }")
    fileStructure.append("\n  }\n\n")
    fileStructure.append(contentsOf: enums)
    fileStructure.append("\n}\n\n")

    //    dump(enums)
    //    dump(singularCases)
  }

  let dir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  let writeURL = dir.appendingPathComponent("Sources/LLVMIntrinsics/IntrinsicsDef.swift")
  print("Done!  Wrote to \(writeURL)")
  // Write out the swift file
  try! fileStructure.joined().write(to: writeURL, atomically: false, encoding: .utf8)
}

run()


