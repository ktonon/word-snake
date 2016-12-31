'use strict';

const conf = require('./conf');

module.exports = require('@microservice/logger')({
  name: 'wordsnake',
  environment: conf.stage,
});
