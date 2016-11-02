var rbcParser = require('pegjs-loader!../parser/rbc.pegjs'); //
//import loaderUtils from 'loader-utils';
//import pegjs from 'pegjs';

module.exports = function loader(source) {
	return `module.exports = "!"`;
  // if (this && this.cacheable) {
  //   this.cacheable();
  // }
  // // const query = loaderUtils.parseQuery(this.query);

  // const ast = rbcParser.parse(source);
  // return `module.exports = ${JSON.stringify(ast)};`;
}
