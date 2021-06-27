const fs = require("fs");
const jison = require("jison");

const args = process.argv.slice(2);

const grammarFile = fs.readFileSync(args[0], "utf8");
const programFile = fs.readFileSync(args[1], "utf8");

const parser = new jison.Parser(grammarFile);
parser.parse(programFile);