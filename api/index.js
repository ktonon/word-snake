'use strict';

const bodyParser = require('koa-bodyparser');
const koa = require('koa');
const cors = require('koa-cors');
const logger = require('./logger');
const logging = require('@microservice/koa-logging');
const middleware = require('./middleware');
const router = require('koa-router');
const serverless = require('serverless-http');
const challenge = require('./challenge');

const routes = router();
routes.use(middleware.error);
routes.use(logging(logger));
routes.use(bodyParser());

routes.use(challenge.routes());
routes.use(challenge.allowedMethods());

routes.get('/', function* () {
  this.body = 'WordSnake API';
});

module.exports.routes = routes;

const app = koa();
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'HEAD', 'OPTIONS'],
}));
app.use(routes.routes());
app.use(routes.allowedMethods());
module.exports.handler = serverless(app);
