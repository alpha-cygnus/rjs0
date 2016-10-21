/* flow */

type PortId = string | number;
type PortKind = string;

class BassNode {
	constructor (parent: BassNode) {
		this.parent = parent;
		this.subNodeList = [];
		this.subNodeMap = {};
		this.subLinkMap = {};
		if (parent) parent.addSubNode(this);
	}
	addSubNode(node: BassNode) {

	}
	getInps(): [PortId] {
		return [];
	}
	getOuts(): [PortId] {
		return [];
	}
	getInp(id: PortId): ?PortIn {
		return null;
	}
	getOut(id: PortId, forPort?: ?PortIn): ?PortOut {
		return null;
	}
	slice(ins: [PortId], outs: [PortId]) {
		return new BassNodeSlice(this, ins, outs);
	}
	stack(other: BassNode) {
		return new BassNodeStack(this, other);
	}
	link(other: BassNode, p: boolean) {
		return new p ? BassNodeParallelLink(this, other) : BassNodeCrossLink(this, other);
	}
	seq(other: BassNode) {
		return new BassNodeSeq(this, other);
	}
}

class BassNodePair extends BassNode {
	constructor (a, b: BassNode) {
		super(a.parent);
		this.a = a;
		this.b = b;
	}
	getInps(): [Port] {
		return this.a.getInps();
	}
	getOuts(): [Port] {
		return this.b.getOuts();
	}
	getInp(id: PortId): ?PortIn {
		return this.a.getInp;
	}
	getOut(id: PortId, forPort?: ?PortIn): ?PortOut {
		return this.b.getOut(id, forPort);
	}
}

class BassNodeLink extends BassNodePair {
	constructor(a, b: BassNode) {
		super(a, b);
		makeLinks();
	}
	makeLinks() {
		for (let out of this.a.getOuts()) {
			for (let inp of this.b.getIns()) {

			}
		}
	}
}

class Port {
	constructor(name: string, kind: PortKind) {
		this.name = name;
		this.kind = kind;
	}
}

class PortIn extends Port {
}

class PortOut extends Port {
	link(other: PortOut) {

	}
}

