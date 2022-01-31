// vite.config.js
import path from "path";
import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import { preprocess } from "./svelte.config";

export default defineConfig({
  cacheDir: "./.vite",
  build: {
    outDir: path.join(__dirname, "..", "dist"),
    emptyOutDir: true,
  },
  server: {
    host: false,
  },
  plugins: [
    svelte({
      /* plugin options */
      preprocess,
    }),
  ],
});
