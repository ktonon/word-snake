# Phoenix with Elm using webpack

First create your Phoenix project using the `phoenix.new` mix task. But omit brunch as follows:

```
mix phoenix.new my_proj --no-brunch
```

## Setting up webpack

To use webpack as your builder, create the following `package.json` file:

```json
{
  "name": "my_proj",
  "version": "0.0.1",
  "main": "index.js",
  "scripts": {
    "build": "webpack",
    "watch": "webpack --watch"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "ace-css": "^1.1.0",
    "css-loader": "^0.23.1",
    "elm-webpack-loader": "^3.0.5",
    "file-loader": "^0.9.0",
    "font-awesome": "^4.6.3",
    "json-server": "^0.8.17",
    "phoenix": "^1.2.0",
    "style-loader": "^0.13.1",
    "url-loader": "^0.5.7",
    "webpack": "^1.13.1"
  },
  "devDependencies": {
    "babel-core": "^6.13.2",
    "babel-loader": "^6.2.4",
    "babel-preset-es2015": "^6.13.2",
    "eslint": "^3.3.0",
    "eslint-config-airbnb": "^10.0.0",
    "eslint-plugin-import": "^1.13.0",
    "eslint-plugin-jsx-a11y": "^2.1.0",
    "eslint-plugin-react": "^6.0.0"
  }
}
```

Now run `npm install`. Next configure webpack by creating the following `webpack.config.js` file:

```js
const path = require('path');

module.exports = {
  entry: {
    app: [
      './web/static/index.js',
    ],
  },

  output: {
    path: path.resolve(`${__dirname}/priv/static`),
    filename: '[name].js',
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          presets: ['es2015'],
        },
      },
      {
        test: /\.(css|scss)$/,
        loaders: [
          'style-loader',
          'css-loader',
        ],
      },
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file?name=[name].[ext]',
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack',
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff',
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader',
      },
    ],

    noParse: /\.elm$/,
  },
};
```

Finally hook the webpack watcher up so that it runs when you run the Phoenix server. Edit `config/dev.exs` by adding a new watcher:

```elixir
config :my_proj, MyProj.Endpoint,
  # ...
  watchers: [
    node: ["node_modules/webpack/bin/webpack.js", "--watch",
      cd: Path.expand("../", __DIR__)]
  ]
```

## Setting up Elm

First install Elm. Then in the root directory of your project run:

```
elm package install
```

Now create the following files:

`web/elm/Main.elm`

```elm
module Main exposing (..)

import Html exposing (Html, div, text)
import Html.App


type alias Model =
    String


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( "Phoenix with Elm using webpacket", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text model ]


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
```

`web/static/index.js`

```js
import 'ace-css/css/ace.css';
import 'font-awesome/css/font-awesome.css';
import Elm from '../elm/Main.elm';
import socket from './js/socket';

const mountNode = document.getElementById('main');
Elm.Main.embed(mountNode);
socket.connect();
```

`web/static/js/socket.js`

```js
import {Socket} from "phoenix";

let socket = new Socket("/socket", {
	params: {token: window.userToken},
	logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data); }
});

export default socket;
```

Change the script loader in `web/templates/layout/app.html.eex` to look like this:

```html
<script src="<%= static_path(@conn, "/app.js") %>"></script>
```

and replace the contents of `web/templates/page/index.html.eex` with this:

```html
<div id="main"></div>
```

Finally to get phoenix to statically serve all files under `priv/static` edit your endpoint file at `lib/my_proj/endpoint.ex` by removing the `only:` argument from the static plug:

```elixir
plug Plug.Static,
  at: "/", from: :my_proj, gzip: false
  # only: ~w(css fonts images js favicon.ico robots.txt)
```

## Trying it out

If everything is configured correctly, you should be able to just

```
mix phoenix.server
```

which will

* start the phoenix server with live reloading
* start the webpack watcher

Navigate to http://localhost:4000 to see the Elm app in action. You should see the text `Phoenix with Elm using webpacket` displayed. Because you are using a webpack watcher and Phoenix live reloading, you should be able to edit your `Main.elm` file and see the changes instantly in your browser without having to refresh.
