'use strict';

const rc = require('rc');

const conf = rc('wordsnake', {
  stage: 'dev',
});

module.exports = conf;
