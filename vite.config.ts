/// <reference types="vitest" />

import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import svg from 'vite-plugin-svgr';
import path from 'path';

export default defineConfig({
  build: {
    sourcemap: true,
  },
  css: {
    preprocessorOptions: {
      scss: {
        loadPaths: ["./node_modules"],
      },
    },
  },
  plugins: [
    RubyPlugin(),
    svg(),
  ],

  resolve: {
    alias: {
      "@js": path.resolve(__dirname, "./app/webpack/js"),
      "@reactjs": path.resolve(__dirname, "./app/webpack/reactjs"),
      "@models": path.resolve(__dirname, "./app/webpack/js/app/models"),
      "@services": path.resolve(__dirname, "./app/webpack/js/services"),
      "@test": path.resolve(__dirname, "./app/webpack/test"),
      "@fixtures": path.resolve(__dirname, "./spec/fixtures"),
      "images": path.resolve(__dirname, "./app/frontend/entrypoints/images"),
      "@styles": path.resolve(__dirname, "./app/webpack/stylesheets"),
    }
  },
  test: {
    globals: true,
    setupFiles: '../../jstest/setupFiles.js',
    environment: 'jsdom',
    dir: "app/webpack"
  }
});
