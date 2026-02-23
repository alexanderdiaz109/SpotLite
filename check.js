const fs = require('fs'); const data = JSON.parse(fs.readFileSync('output.txt', 'utf8').split('Latest evaluation:\r\n')[1]); console.log(JSON.stringify(data, null, 2));
