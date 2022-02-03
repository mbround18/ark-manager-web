<script lang="ts">
    import './global.css';
    import Header from './prefabs/header.svelte';
    import {onMount} from "svelte";
    import {setupLocale} from "./locale";
    import {fetchedStatus} from "./state/fetchedStatus";

    setupLocale("en")
    let showControls = false;
    let components = [];

    $: {
        if (showControls) {
            components = [
                import('./prefabs/server-actions.svelte'),
                import('./prefabs/update-server.svelte')
            ]
        }
    }

    onMount(async () => {
        // @ts-ignore
        setupLocale(localStorage.getItem("locale") ?? "en")
        // @ts-ignore
        await fetchedStatus.subscribe(v => showControls = v);


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
                {#each components as component}
                    {#await component then c}
                        <svelte:component this={c.default}/>
                    {/await}
                {/each}
                {#if false}
                    {#await import('./prefabs/mod-manager.svelte') then c}
                        <svelte:component this={c.default}/>
                    {/await}
                {/if}
            {/if}
        </div>
        <div class="w-11/12">
            {#await import('./prefabs/action-log.svelte') then c}
                <svelte:component this={c.default}/>
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
