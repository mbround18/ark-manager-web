<script>
    export let id = "stop-light-status"
    export let content = false
    export let label = ""
    export let block = false
    export let link = false
</script>

<div>
    {#if (!link)}
        <label for={id} class:block={block}>{
            label
        }</label>
    {/if}
    {#if typeof content === "boolean"}
        <!--suppress XmlDuplicatedId -->
        <p id={id} class:inline={!block}>
            {content ? "🟢" : "🔴" }
        </p>
    {:else if link}
        <!--suppress XmlDuplicatedId -->
        <a id={id} class:inline={!block} href={content}>
            {label ?? content}
        </a>
    {:else}
        <!--suppress XmlDuplicatedId -->
        <p id={id} class:inline={!block}>
            {content}
        </p>
    {/if}
</div>


<style lang="scss">
    a {
      @apply text-blue-600;
    }
</style>
