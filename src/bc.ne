S = statement

statements = h:statement t:(SSEP s:statement { return s})* { return [h].concat(t) }

statement = let / func / chain / import

let = id:id EQ v:chain { return `this.set({${id}: ${v}})` }

func = Id args? EQ chain

import = OBRACE imp (COMMA imp)* CBRACE EQ chain

imp = id (":" id)? / Id (":" Id)?

chain = h:stack t:(chainOp s:stack { return s })* { return t.length ? '(' + [h].concat(t).join(').chain(') + ')' : h }

stack = h:slice t:(COMMA s:slice {return s})* { return t.length ? '(' + [h].concat(t).join(').stack(') + ')' : h }

slice = is:inpSlice? sl:prim os:outSlice? { return (is || os) ? `${sl}.slice(${is}, ${os})` : sl }

prim = p:(cons / ref / group) { return p }

cons =
	id:Id as:cargs? { return `${id}(${(as || []).join(', ')})` }
    / MUL n:NUM { return `Gain(${n})` }
    / n:NUM { return `Const(${n})` }

ref = id:id { return `this.get({${id}})` }

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
