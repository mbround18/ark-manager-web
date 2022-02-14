<script lang="ts">
    import Card from "../components/card.svelte"
    import {onMount} from "svelte";
    import {fetchLogs} from "../http";

    let sources = [];
    let activeSource = "";

    onMount(async ()=> {
        const {data: {log_files}} = await fetchLogs();
        sources = log_files;
        if (log_files?.[0]) {
            activeSource = log_files[0]
        }
    })


    function isActive(source) {
        return activeSource === source
        // return activeLog.length > 0 ? activeLog === source : index === 0
    }

    function setIsActive(source) {
        return () => {
            console.log("Setting activeLog\nbase:", activeSource, "\nnew:\n", source)
            activeSource = source
        }
    }

    function simplifySourceName(source: string) {
        const segments = source.split("/");
        return segments[segments.length - 1]
    }
</script>

<Card {...$$props} class="min-w-fit max-w-7xl" >
    <div id="action-log">
        <div class="flex flex-row">
            {#each sources as source}
                <div>
                    <button
                            class="truncate"
                            on:click={setIsActive(source)}
                    >{simplifySourceName(source)}</button>
                </div>
            {/each}
        </div>
        <hr class="mb-4 mt-2" />
        {#if (!!activeSource)}
            {#key activeSource}
                <div data-source={activeSource}>
                    {#await import('../components/output-log.svelte') then c}
                        <svelte:component this={c.default} source={activeSource} />
                    {/await}
                </div>
            {/key}
        {/if}
    </div>
</Card>

<style lang="scss">

</style>
