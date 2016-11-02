import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import rbcParser from './parser/rbc.pegjs';

//import rbcLoader from './loader/rbc.js';

import rbcTest from 'includes!./rbc/test.rbc';

//const rbcParser = require('pegjs!./parser/rbc.pegjs');

class App extends Component {
  render() {
    try {
      var parseResult = rbcParser.parse(rbcTest);
    } catch(e) {
      if (e.location) {
        console.error(e.location, e.message);
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
          {JSON.stringify(parseResult, null, '  ')}
        </pre>
      </div>
    );
  }
}

export default App;
