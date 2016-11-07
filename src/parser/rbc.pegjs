{
	function isArray(o) {
		return (o && (typeof o == 'object') && ('length' in o));
	}
	function *jsonML2X(obj) {
		let chi = [];
		if (isArray(obj)) {
			let a = obj[1];
			if (typeof a == 'object') {
				if (!isArray(a)) chi = obj.slice(2);
				else {
					a = null; chi = obj.slice(1);
				}
			} else {
				a = null;
				chi = obj.slice(1);
			}
			let tag = `<${obj[0]}`;
			if (a) {
				tag += Object.keys(a).map(k => ` ${k}="${a[k]}"`).join('');
			}
			if (chi.length) {
				tag += '>';
				if (chi.length == 1 && (typeof chi[0]) in {string:1, number: 1}) {
					yield `${tag}${chi[0]}</${obj[0]}>`;
				} else {
					yield tag;
					for (let c of chi) {
						yield * [...jsonML2X(c)].map(s => '   ' + s);
					}
					yield `</${obj[0]}>`;
				}
			} else {
				yield tag + '/>';
			}
		} else {
			yield obj;
		}
	}
	function locationString(loc) {
		loc = loc || location();
		return `${loc.start.line}:${loc.start.column}-${loc.end.line}:${loc.end.column}`;
	}
	function elem(name, attr, children) {
		attr = attr || {};
		children = children || [];
		switch(arguments.length) {
			case 1: attr = {}; children = []; break;
			case 2: 
			  if (isArray(attr)) {
				  children = attr;
				  attr = {};
			  }
			  break;
		}
		attr.at = locationString();
		let res = [name];
		if (Object.keys(attr).length) res.push(attr);
		return res.concat(children);
	}
}

S = ss:statements { return {xml: [...jsonML2X(elem('Module', ss))].join('\n'), json: ss} }

statements = h:statement t:(SSEP s:statement { return s})* SSEP? { return [h].concat(t) }

statement = let / decl / chain / import

let = ln:letName EQ v:chain {
	let {name, range} = ln || {};
	if (range) {
		let attr = {from: range.a, to: range.b};
		if (name) attr.name = name;
		return elem('LetArr', attr, [v]);
	} else {
		if (!name) return res;
		return elem('Let', {name}, [v]);
	}
	return elem('Let', {name: ln.name}, [v])
}

decl = Id args:args? EQ chain:chain { return elem('Decl', {args: (args || []).join(',')}, [chain]) }

args = OPARENS h:arg t:(COMMA a:arg { return a })* CPARENS { return [h].concat(t) }

arg = id

import = OBRACE h:imp t:(COMMA x:imp { return x })* CBRACE EQ v:chain {
	return elem('Import', [h].concat(t).reduce((a, x) => Object.assign(a, x), {}), [v]);
}

imp
	= name:id as:(_":" as:id { return as })? { return { ['arg-' + name]: as || name } }
	/ name:Id as:(_":" as:Id { return as })? { return { ['arg-' + name]: as || name } }

chain = h:stack t:(op:chainOp s:stack { return {op, s} })* {
	if (!t.length) return h;
	return [h].concat(t).reduce((a, {op, s}) => elem(op, [a, s])); 
	return t.length ? elem('Chain', [h].concat(t)) : h
}

stack = h:slice t:(COMMA s:slice {return s})* { return t.length ? elem('Stack', [h].concat(t)) : h }

slice = is:inpSlice? sl:prim os:outSlice? {
	let res = sl; //['Slice', [sl].concat(is)];
	if (is) res = elem('SliceInp', [res].concat(is));
	if (os) res = elem('SliceOut', [res].concat(os));
	return res;
	//return (is || os) ? `${sl}.slice(${is}, ${os})` : sl
}

prim = cons / ref / group / func

func = OBRACE args:args c:CODE CBRACE { return elem('Func', { args: args.join(',') }, c) }

cons =
	id:Id as:cargs? ln:letName? {
		let {name, range} = ln || {};
		let res = elem('New', {name: id}, as);
		if (range) {
			let attr = {from: range.a, to: range.b};
			if (name) attr.name = name;
			return elem('LetArr', attr, [res]);
		} else {
			if (!name) return res;
			return elem('Let', {name}, [res]);
		}
	}
	/ MUL n:prim? { return elem('Gain', n ? [n] : []) }
	/ n:num { return n }

letName
	= name:id range:range? { return {name, range} }
	/ range:range { return { range } }

range = LODASH nr:numrange { return nr }

numrange = a:NUM b:(DASH b:NUM { return b })? { return {a, b: b || a} }

num = value:NUM {
	return elem('Num', {value});
	//return elem('Num', {}, [value])
}

ref = name:id {
	return elem('Num', {name});
	//return elem('Num', {}, [name])
}

group = OPARENS ss:statements CPARENS { return ss.length > 1 ? elem('Seq', ss) : ss[0] }

cargs = OPARENS h:carg t:(COMMA a:carg { return a })* CPARENS { return [h].concat(t) }

carg = prim

inpSlice = portSlice

outSlice = portSlice

portSlice = OBRACKET h:ps t:(COMMA p:ps { return p})* CBRACKET { return [h].concat(t) }

ps
	= NUM
	/ id

chainOp
	= PCHAIN { return 'PConnect' }
	/ XCHAIN { return 'XConnect' }

PCHAIN = _ ('=>' / '||') _

XCHAIN = _ ('->' / '|') _

EQ = _ "=" _

CRLF = [\n\r]

WS = [\t] / ' '

_ = WS*

__ = (WS / CRLF)*

SSEP = _ (";" / CRLF)+ _

OBRACE = _ "{" _

CBRACE = _ "}" _

OPARENS = _ "(" _

CPARENS = _ ")" _

OBRACKET = _ "[" _

CBRACKET = _ "]" _

COMMA = _ "," _

AZ = [A-Z]
az = [a-z]

DIG = [0-9]

W = AZ / az / DIG

id = _ id:$(az W*) _ { return id }

Id = _ id:$(AZ W*) _ { return id }

MUL = _ "*" _

DIGS = $(DIG+)

NUM = _ n:$(("+" / "-")? DIG+ ("." DIG+)?) _ { return parseFloat(n) }

LODASH = '_'

DASH = '-'

CODE = $(CODE_ELEM*)
CODE_ELEM = [^{}"'] / '{' CODE '}' / '"' ([^"\] / [\] [.])* '"'

