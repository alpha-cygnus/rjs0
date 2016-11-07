import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import rbcParser from './parser/rbc.pegjs';

import babel from 'babel-core';

//import rbcLoader from './loader/rbc.js';

import rbcTest from 'includes!./rbc/test.rbc';

import rbcTest2 from 'babel!includes!./loader/rbc.js!./rbc/test.rbc';

//const rbcParser = require('pegjs!./parser/rbc.pegjs');

class App extends Component {
  render() {
    console.log('rendring');

    // console.log('rbcTest3.4', rbcTest2);
    try {
      let pr = rbcParser.parse(rbcTest);
      var {xml, json} = pr;
      console.log(xml);
      babel.transform(xml, {
        "presets": ["react"]
      });
    } catch(e) {
      if (e.location) {
        console.error(e.location, e.message);
      } else {
        console.error(e);
      }
    }
    
    return (
      <div className="App">
        <div className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h2>Welcome to React</h2>
        </div>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>
        <pre>
          {rbcTest}
        </pre>
        <pre style={ {textAlign: 'left'} }>
          {xml}
        </pre>
        <pre style={ {textAlign: 'left'} }>
          {JSON.stringify(json)}
        </pre>
        <pre style={ {textAlign: 'left'} }>
          {rbcTest2}
        </pre>
      </div>
    );
  }
}

export default App;
