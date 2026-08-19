import path from "path";
import { fileURLToPath } from "url";
import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";
import svelteConfig from "./svelte.config.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

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
      preprocess: svelteConfig.preprocess,
    }),
  ],
});
