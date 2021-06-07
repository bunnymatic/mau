const path = require("path");
const webpackRootDir = path.resolve(__dirname, "../../../app/webpack");

module.exports = {
  resolve: {
    alias: {
      "@js": path.resolve(webpackRootDir, "js"),
      "@models": "js/app/models",
      "@services": path.resolve(webpackRootDir, "js/services"),
      "@reactjs": path.resolve(webpackRootDir, "reactjs/"),
    },
  },
};
