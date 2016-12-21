require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./style.scss');
require('./index.html');

const doc = document; // eslint-disable-line no-undef
const config = require('./config.json');
const Elm = require('./Main.elm');

const mountNode = doc.getElementById('main');
const app = Elm.Main.embed(mountNode);

setTimeout(() =>
  app.ports.config.send(config),
0);
