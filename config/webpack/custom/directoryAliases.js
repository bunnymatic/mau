const path = require("path");
const webpackRootDir = path.resolve(__dirname, "../../../app/webpack");

module.exports = {
  resolve: {
    alias: {
      "@js": path.resolve(webpackRootDir, "js"),
      "@components": path.resolve(webpackRootDir, "components"),
    },
  },
};
