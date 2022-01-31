<script lang="ts">
    import {text} from "../locale";

    export let name = "User"
</script>

<div class="flex flex-row-reverse flex-row">
    <h1>{$text("prefab.header.greeting", {values: {name}})}</h1>
</div>

<style lang="scss">
  div {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    width: auto;
    height: var(--header-height);
    @apply w-full bg-emerald-700 text-white rounded p-2;
  }
</style>
