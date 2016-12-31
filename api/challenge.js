'use strict';

const AWS = require('aws-sdk');
const base64 = require('base64'); // eslint-disable-line import/no-unresolved
const BPromise = require('bluebird');
const genId = require('./gen-id');
const router = require('koa-router');

AWS.config.setPromisesDependency(BPromise);
const dynamodb = new AWS.DynamoDB({ apiVersion: '2012-08-10' });
const api = module.exports = router({ prefix: '/challenge' });
const table = 'wordsnake_challenge';

const toChallenge = data => ({
  id: data.Item.id.S,
  board: data.Item.board.S,
  shape: data.Item.shape.S,
  results: data.Item.results.L.map(result => ({
    player: result.M.player.S,
    score: parseInt(result.M.score.N, 10),
    words: result.M.words.SS,
  })),
});

const getById = id => dynamodb.getItem({
  TableName: table,
  Key: { id: { S: id } },
}).promise().then(toChallenge);

api.get('/:id', function* () {
  this.body = yield getById(this.params.id);
});

const validateResult = (context) => {
  const player = context.request.body.player;
  const score = context.request.body.score;
  const encodedToken = context.request.body.token;
  if (!player || !score || !encodedToken) {
    context.throw(400, 'Missing parameter');
    return null;
  }
  let token;
  try {
    token = JSON.parse(base64.atob(encodedToken));
  } catch (err) {
    context.throw(400, 'Invalid token encoding');
    return null;
  }
  const board = token.b;
  const shape = token.s;
  const words = token.w;
  if (!board || !shape || !words
    || !/^[A-Z]{9,}$/.test(board)
    || !/^(\d+)x(\d+)/.test(shape)
    || !/^(([A-Z]{3,})(,[A-Z]{3,})*)?$/.test(words)
  ) {
    context.throw(400, 'Invalid token');
    return null;
  }
  return {
    board: board,
    shape: shape,
    result: {
      M: {
        player: { S: player.toString() },
        score: { N: parseInt(score.toString(), 10).toString() },
        words: { SS: words.split(',') },
      },
    },
  };
};

api.post('/', function* () {
  const id = genId();
  const v = validateResult(this);
  if (v) {
    this.body = yield dynamodb.putItem({
      TableName: table,
      Item: {
        id: { S: id },
        board: { S: v.board },
        shape: { S: v.shape },
        results: { L: [v.result] },
      },
    }).promise().then(() => getById(id));
  }
});

api.post('/:id', function* () {
  const id = this.params.id;
  const v = validateResult(this);
  this.body = yield dynamodb.updateItem({
    TableName: table,
    Key: { id: { S: id } },
    AttributeUpdates: {
      results: {
        Action: 'ADD',
        Value: { L: [v.result] },
      },
    },
  }).promise().then(() => getById(id));
});
