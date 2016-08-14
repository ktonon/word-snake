import 'ace-css/css/ace.css';
import 'font-awesome/css/font-awesome.css';
import Elm from '../elm/Main.elm';
import socket from './js/socket';

const mountNode = document.getElementById('main');
Elm.Main.embed(mountNode);
socket.connect();
