const path = require("path");
const webpackRootDir = path.resolve(__dirname, "../../../app/webpack");

module.exports = {
  resolve: {
    alias: {
      "@components": path.resolve(webpackRootDir, "components"),
      "@js": path.resolve(webpackRootDir, "js"),
      "@services": path.resolve(webpackRootDir, "components/services"),
    },
  },
};
