require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./style.scss');
require('./index.html');

const nav = window.navigator; // eslint-disable-line no-undef
const doc = document; // eslint-disable-line no-undef
const config = Object.assign({
  isMobile: /mobile/i.test(nav.appVersion),
}, require('./config.json'));
const Elm = require('./Main.elm');

const font = doc.createElement('link');
font.setAttribute('href', 'https://fonts.googleapis.com/css?family=Josefin+Sans');
font.setAttribute('rel', 'stylesheet');
doc.head.appendChild(font);

const mountNode = doc.getElementById('main');
const app = Elm.Main.embed(mountNode, {
  api: config.apiEndpoint,
  dictionaryApi: config.dictionaryApiEndpoint,
});

setTimeout(() =>
  app.ports.config.send(config),
0);
