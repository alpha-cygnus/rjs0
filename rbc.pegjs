{
	function gen(s, vs) {
    	return {
        	code: s.replace(/\${(\w+)}/g,
	        	(_, i) => typeof vs[i] == 'object' ? vs[i].code : vs[i]),
            location: location(),
            vs: vs,
        }
    }
    function genCons(cons, as) {
    	return gen(
        	"new this.get('${cons}')(${as})",
        	{cons, as: genList(as || [])}
        );
    }
    function genList(list, fmt = "$", sep = ", ") {
    	return gen(
        	list.map((_, i) => fmt.replace("$", "${" + i + "}").join(sep),
            list);
    }
}

S = statements

statements = h:statement t:(SSEP s:statement { return s})* { return [h].concat(t) }

statement = let / func / chain / import

let = id:id EQ v:chain { return gen("this.set('${id}', ${v})", {id, v}) }

func = Id args? EQ chain

import = OBRACE h:imp t:(COMMA x:imp { return x })* CBRACE EQ v:chain {
	return [h].concat(t).reduce((a, x) => Object.assign(a, x), {});
}

imp
	= name:id as:(_":" as:id { return as })? { return { [name]: as || name } }
	/ name:Id as:(_":" as:Id { return as })? { return { [name]: as || name } }

chain = h:stack t:(chainOp s:stack { return s })* { return t.length ? genList([h].concat(t), "($)", ".chain") : h }

stack = h:slice t:(COMMA s:slice {return s})* { return t.length ? genList([h].concat(t), "($)", ".chain") : h }

slice = is:inpSlice? sl:prim os:outSlice? { return (is || os) ? `${sl}.slice(${is}, ${os})` : sl }

prim = p:(cons / ref / group) { return p }

cons =
	id:Id as:cargs? { return genCons(id, as) }
    / MUL n:NUM? { return genCons('Gain', [n || 1]) }
    / n:NUM { return genCons('Const', [n]) }

ref = id:id { return gen("this.get('${id}')", {id}) }

group = OPARENS ss:statements CPARENS { return ss.length > 1 ? '(' + ss.join(').follow(') + ')' : ss[0] }

args = '(' h:arg t:(COMMA arg)* ')' { return [h].concat(t) }

arg = id

cargs = OPARENS h:carg t:(COMMA a:carg { return a })* CPARENS { return [h].concat(t) }

carg = prim

inpSlice = portSlice

outSlice = portSlice

portSlice = OBRACKET h:ps t:(COMMA p:ps { return p})* CBRACKET { return [h].concat(t) }

ps = n:$(DIG+) { return parseInt(n, 10) }

chainOp
	= PCHAIN { return '=>' }
	/ XCHAIN { return '->' }

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
