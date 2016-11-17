require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html');

const doc = document; // eslint-disable-line no-undef
const Elm = require('./Main.elm');

const mountNode = doc.getElementById('main');
Elm.Main.embed(mountNode);
