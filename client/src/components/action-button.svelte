<script lang="ts">
    export let type: "primary" | "secondary" | "ok" | "err" | "warn" | "none" = "ok";
    export let onClick = () => console.log("Clicked");
    export let tooltip = ""
    export let classNames = []
</script>

<button
    class={[
        "rounded",
        ...(type !== "none" ? ["m-1", "p-2"] : []),
      `${type}-btn`,
      ...(typeof classNames === "string" ? [classNames] : classNames)
    ].join(" ")}
    class:tooltip={tooltip.length > 0}
    on:click={onClick}
>
    <slot />
</button>

<style lang="scss">
    button {
      @apply w-full;
      &.primary-btn {
        @apply bg-blue-600;
        &:hover {
          @apply bg-blue-500;
        }
      }
      &.secondary-btn, &.ok-btn  {
        @apply bg-green-600;
        &:hover {
          @apply bg-green-500;
        }
      }
      &.err-btn {
        @apply bg-red-600;
        &:hover {
          @apply bg-red-500;
        }
      }
      &.warn-btn {
        @apply bg-yellow-600;
        &:hover {
          @apply bg-yellow-500;
        }
      }
    }
</style>
