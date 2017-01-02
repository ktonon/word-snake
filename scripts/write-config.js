const fs = require('fs');
const path = require('path');
const rc = require('rc');

const conf = rc('wordSnake', {
  endpoints: {
    api: 'http://localhost:6413',
    app: 'http://localhost:8080',
    dictionaryApi: 'http://localhost:7631',
  },
  language: 'en',
});

const outConf = path.resolve(`${__dirname}/../app/config.json`);
fs.writeFileSync(outConf, JSON.stringify(conf));
