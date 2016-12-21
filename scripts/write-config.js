const fs = require('fs');
const path = require('path');
const rc = require('rc');

const conf = rc('wordSnake', {
  apiEndpoint: 'http://localhost:7631',
  language: 'en',
});

const outConf = path.resolve(`${__dirname}/../app/config.json`);
fs.writeFileSync(outConf, JSON.stringify(conf));
