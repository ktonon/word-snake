const randomstring = require('randomstring');

// 57 ** 7 = 1,954,897,493,193
const genId = () => randomstring.generate({
  length: 7,
  charset: 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789',
});

module.exports = genId;
