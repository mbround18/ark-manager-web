<script lang="ts">
    import './global.css';
    import Header from './prefabs/header.svelte';
    import {onMount} from "svelte";
    import {setupLocale} from "./locale";

    setupLocale("en")

    onMount(() => {
        // @ts-ignore
        setupLocale(localStorage.getItem("locale") ?? "en")
    })

    let name = "Michael"
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
            {#await import('./prefabs/server-actions.svelte') then c}
                <svelte:component this={c.default}/>
            {/await}
            {#await import('./prefabs/update-server.svelte') then c}
                <svelte:component this={c.default}/>
            {/await}
            {#if false}
                {#await import('./prefabs/mod-manager.svelte') then c}
                    <svelte:component this={c.default}/>
                {/await}
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
