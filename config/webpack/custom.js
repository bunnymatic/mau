const path = require("path");

module.exports = {
  resolve: {
    alias: {
      "@js": path.resolve(__dirname, "..", "..", "app/webpack/js"),
      "@components": path.resolve(
        __dirname,
        "..",
        "..",
        "app/webpack/components"
      )
    }
  }
};
