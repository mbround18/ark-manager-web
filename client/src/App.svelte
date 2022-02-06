<script lang="ts">
    import './global.css';
    import Header from './prefabs/header.svelte';
    import {onMount, onDestroy} from "svelte";
    import {setupLocale} from "./locale";
    import {fetchedStatus} from "./state/fetchedStatus";
    import {fetchState} from "./state/agentState";
    import {installed} from "./state/installed";

    setupLocale("en")
    let showControls = false;
    let agentStateInterval;

    onMount(async () => {
        // @ts-ignore
        setupLocale(localStorage.getItem("locale") ?? "en")
        // @ts-ignore
        await fetchedStatus.subscribe(v => showControls = v);
        await fetchState();
        agentStateInterval = setInterval(fetchState, 2000);
    })
    onDestroy(()=> {
        if (agentStateInterval) {
            clearInterval(agentStateInterval)
        }
    })
</script>

<div id="app">
    <Header />
    <div id="content" class="flex-col pb-16">
        <div id="block-a">
            {#await import('./prefabs/thank-you.svelte') then c}
                <svelte:component this={c.default}/>
            {/await}
            {#await import('./prefabs/server-status.svelte') then c}
                <svelte:component this={c.default}/>
            {/await}
            {#if showControls}
                {#await import("./prefabs/server-actions.svelte") then c}
                    <svelte:component this={c.default}/>
                {/await}
                {#if $installed}
                    {#await import("./prefabs/update-server.svelte") then c}
                        <svelte:component this={c.default}/>
                    {/await}
                    {#if false}
                        {#await import('./prefabs/mod-manager.svelte') then c}
                            <svelte:component this={c.default}/>
                        {/await}
                    {/if}
                {/if}
            {/if}
        </div>
        <div class="flex flex-row flex-wrap gap-4">
            {#await import('./prefabs/action-log.svelte') then c}
                <svelte:component this={c.default} />
            {/await}
            {#await import('./prefabs/configuration-management.svelte') then c}
                <svelte:component this={c.default} />
            {/await}
        </div>
    </div>
</div>

<style lang="scss">
    #app {
      @apply h-screen w-full;
    }
    #content {
      @apply m-4;
    }
    #content, #block-a {
      @apply flex flex-auto flex-wrap gap-4;
      padding-top: var(--header-height);
    }
</style>
