process.env.NODE_ENV = process.env.NODE_ENV || "production";

const environment = require("./environment");

const config = environment.toWebpackConfig();

// Don't build sourcemaps
delete config.devtool;

module.exports = config;
