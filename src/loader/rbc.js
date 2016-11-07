//var rbcParser = require('pegjs'); //
var rbcParser = require('../parser/rbc');

module.exports = function loader(source) {
	let parsed = rbcParser.parse(source);
	//parsed.xml;
	return `module.exports = ${parsed.xml}`;
  // if (this && this.cacheable) {
  //   this.cacheable();
  // }
  // // const query = loaderUtils.parseQuery(this.query);

  // const ast = rbcParser.parse(source);
  // return `module.exports = ${JSON.stringify(ast)};`;
}
