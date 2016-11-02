{
	function isArray(o) {
    	return (o && typeof o == 'object' && ('length' in o));
    }
	function *jsonML2X(obj) {
    	if (isArray(obj)) {
        	let a = obj[1];
            if (typeof a == 'object') {
            	if (isArray(a)) chi = obj.slice(2);
                else {
                	a = null; chi = obj.slice(1);
                }
            }
            let tag = `<${obj[0]}`;
            if (a) {
            	tag += Object.keys(a).map(k => ` ${k}="${a[k]}"`);
            }
            if (chi.length) {
            	tag += '>';
                yield tag;
                yield * chi.map(c => jsonML2X(c));
                yield `</${obj[0]}>`;
            } else {
            	yield tag += '';
            }
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
              if (isArray(attr.length)) {
                  children = attr;
                  attr = {};
              }
              break;
        }
        //attr.location = locationString();
        let res = [name];
        if (Object.keys(attr).length) res.push(attr);
        return res.concat(children);
    }
}

S = ss:statements { return elem('Module', ss) }

statements = h:statement t:(SSEP s:statement { return s})* SSEP? { return [h].concat(t) }

statement = let / func / chain / import

let = id:id EQ v:chain { return gen("this.set('${id}', ${v})", {id, v}) }

func = Id args? EQ chain

import = OBRACE h:imp t:(COMMA x:imp { return x })* CBRACE EQ v:chain {
	return [h].concat(t).reduce((a, x) => Object.assign(a, x), {});
}

imp
	= name:id as:(_":" as:id { return as })? { return { [name]: as || name } }
	/ name:Id as:(_":" as:Id { return as })? { return { [name]: as || name } }

chain = h:stack t:(op:chainOp s:stack { return {op, s} })* {
	if (!t.length) return h;
    return [h].concat(t).reduce((a, {op, s}) => elem(op, a, s)); 
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

prim = p:(cons / ref / group) { return p }

cons =
	id:Id as:cargs? { return elem(id, as) }
	/ MUL n:prim? { return elem('Gain', n ? [n] : []) }
	/ n:num { return n }

num = n:NUM { return elem('Num', [n]) }

ref = id:id { return elem('Ref', [id]) }

group = OPARENS ss:statements CPARENS { return ss.length > 1 ? elem('Seq', ss) : ss[0] }

args = '(' h:arg t:(COMMA arg)* ')' { return [h].concat(t) }

arg = id

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

NUM = _ n:$(("+" / "-")? DIG+ ("." DIG+)?) _ { return parseFloat(n) }
