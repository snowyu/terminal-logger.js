## terminal-logger [![npm](https://img.shields.io/npm/v/terminal-logger.svg)](https://npmjs.org/package/terminal-logger)

[![Build Status](https://img.shields.io/travis/snowyu/terminal-logger.js/master.svg)](http://travis-ci.org/snowyu/terminal-logger.js)
[![Code Climate](https://codeclimate.com/github/snowyu/terminal-logger.js/badges/gpa.svg)](https://codeclimate.com/github/snowyu/terminal-logger.js)
[![Test Coverage](https://codeclimate.com/github/snowyu/terminal-logger.js/badges/coverage.svg)](https://codeclimate.com/github/snowyu/terminal-logger.js/coverage)
[![downloads](https://img.shields.io/npm/dm/terminal-logger.svg)](https://npmjs.org/package/terminal-logger)
[![license](https://img.shields.io/npm/l/terminal-logger.svg)](https://npmjs.org/package/terminal-logger)


Terminal-logger prints the message to the console.

All logs are done against STDERR, letting you stdout for meaningfull
value and redirection, should you need to generate output this way.

* Customize colorful status
* Single-line update
* table supports

## Usage

```js
logger  = require('./')('test')

logger
  .write()
  .info('Doing something')
  .force('Forcing filepath %s', 'some path')
  .conflict('on %s', 'model.js')
  .ok('good')
  .error('sth error')
  .create(logger.table([['a:', 213], ['b:', 111]]))
  .write()
  .tick('<-This is ok')
  .cross('<-this is a wrong cross flag')
```

the result:

![result](./img/result.png)

Single-line update:

```coffee
log = require('terminal-logger/lib/single-line')('test')
dash = '>'
singleLineLog = ->
   dash = dash.replace('>', '->')
   log.info("update:", dash)
   dash = '>' if dash.length > 60
   setTimeout(singleLineLog, 500)
singleLineLog()
```

the result:

![single-line-result](./img/single-line-result.gif)

## API


## TODO


## License

MIT
