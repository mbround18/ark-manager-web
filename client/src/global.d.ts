declare module "*.svelte" {
  import { SvelteComponent } from "svelte";
  const comp: SvelteComponent;
  export default comp;
}

declare module "*.svg" {
  export default {};
}
