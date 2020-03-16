#!/usr/bin/env node

const browserslist = require("browserslist");
const fs = require("fs");

fs.writeFileSync("./browsers.json", JSON.stringify(browserslist()));
