import 'ace-css/css/ace.css';
import 'font-awesome/css/font-awesome.css';
import Elm from '../elm/Main.elm';
import socket from './js/socket';

const mountNode = document.getElementById('main'); // eslint-disable-line no-undef
Elm.Main.embed(mountNode);
socket.connect();
