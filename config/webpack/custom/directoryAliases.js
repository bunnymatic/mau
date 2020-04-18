const path = require("path");
const webpackRootDir = path.resolve(__dirname, "../../../app/webpack");

module.exports = {
  resolve: {
    alias: {
      "@js": path.resolve(webpackRootDir, "js"),
      "@angularjs": path.resolve(webpackRootDir, "angularjs/"),
      "@components": path.resolve(webpackRootDir, "angularjs/components"),
      "@services": path.resolve(webpackRootDir, "angularjs/services"),
    },
  },
};
