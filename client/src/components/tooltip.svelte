<script lang="ts">
    export let tooltip=""
</script>

<div class="tooltip">
    <slot class="w-full h-full" />
     <p class="tooltip-message">{tooltip}</p>
</div>

<style lang="scss" >
  .tooltip {
    position: relative;
    &:hover .tooltip-message {
      visibility: visible;
    }
    & .tooltip-message {
      @apply mt-4 text-sm;
      z-index: 1;
      visibility: hidden;
      position: absolute;
    }
  }
</style>
