const fs = require('fs');

const data = fs.readFileSync(`${__dirname}/../eng-pairs.txt`)
  .toString()
  .split('\n')
  .filter(x => !!x)
  .map(x => parseInt(x, 10))
  .reduce((acc, x) => {
    let f = acc[acc.length - 1];
    if (!f || f.length === 26) {
      f = [];
      acc.push(f);
    }
    f.push(x);
    return acc;
  }, []);

const data2 = data.map((freq, i) => freq.map((x, j) => x + data[j][i]));
const data3 = data2.map((freq) => {
  const t = freq.reduce((sum, x) => sum + x);
  return freq.map(x => Math.round((x * 1000) / t));
});

const toChar = index => String.fromCharCode(65 + index);
const out = fs.openSync(`${__dirname}/../app/Board/EngPair.elm`, 'w');
fs.writeSync(out, `module Board.EngPair exposing (..)

englishPair : Char -> List (Int, Char)
englishPair other =
    case other of
`);
data3.forEach((freq, i) => {
  fs.writeSync(out, `        '${toChar(i)}' ->
            [ `);
  fs.writeSync(out, freq
    .map((x, j) => `(${x}, '${toChar(j)}')`)
    .join(`
            , `)
  );
  fs.writeSync(out, `
            ]

`);
});
fs.writeSync(out, `        _ ->
            [ ( 81, 'A' )
            , ( 14, 'B' )
            , ( 27, 'C' )
            , ( 43, 'D' )
            , ( 120, 'E' )
            , ( 23, 'F' )
            , ( 20, 'G' )
            , ( 59, 'H' )
            , ( 73, 'I' )
            , ( 1, 'J' )
            , ( 6, 'K' )
            , ( 39, 'L' )
            , ( 26, 'M' )
            , ( 69, 'N' )
            , ( 76, 'O' )
            , ( 18, 'P' )
            , ( 1, 'Q' )
            , ( 60, 'R' )
            , ( 62, 'S' )
            , ( 91, 'T' )
            , ( 28, 'U' )
            , ( 11, 'V' )
            , ( 20, 'W' )
            , ( 1, 'X' )
            , ( 21, 'Y' )
            , ( 1, 'Z' )
            ]
`);
fs.closeSync(out);
