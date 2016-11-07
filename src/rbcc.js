const babel = require('babel-core');

const pegjs = require('pegjs');

const fs = require('fs');

const grammar = fs.readFileSync('parser/rbc.pegjs').toString();

const src = fs.readFileSync(process.argv[2]).toString();

console.log(src);

const parser = pegjs.generate(grammar);

const pr = parser.parse(src);

console.log(pr.xml);

const babelified = babel.transform(pr.xml, { presets: ['react']})

console.log(babelified.code);