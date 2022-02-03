<script lang="ts">
    import Card from '../components/card.svelte'
    import LabeledEntity from '../components/labeled-entity.svelte'
    import {text} from "../locale";
    import {onDestroy, onMount} from "svelte";
    import {installed} from "../state/installed";
    import {fetchedStatus} from "../state/fetchedStatus";
    import {get as stateGet} from 'svelte/store';
    import {fetchStatus} from "../http";

    let statusInterval;
    let status = {
        instance: "unknown",
        running: false,
        listening: false,
        installed: false,
        build_id: "0"
    }

    async function mergeStatus() {
        const {data} = await fetchStatus();
        const localStatus = {...status};
        Object.entries(data).forEach(([key, value]) => {
            if (typeof value === "string") {
                if (value.length > 0) {
                    localStatus[key] = value
                } else {
                    delete localStatus[key]
                }
            } else {
                localStatus[key] = value
            }
        })
        status = localStatus
        if (!stateGet(fetchedStatus)) {
            fetchedStatus.set(true);
        }
        installed.set(status.installed);
    }

    onMount(async ()=> {
        statusInterval = setInterval(mergeStatus, 5000)
        await mergeStatus();
    })

    onDestroy(() => {
        clearInterval(statusInterval);
    })

    function isLink(text: string): boolean {
        return /(hs?ttp|steam)/g.test(text)
    }
</script>

<svelte:head>
    <title>{$text("app.title")}</title>
</svelte:head>

<Card>
    <div class="flex flex-col justify-items-stretch">
        {#each Object.keys(status) as statusKey}
            {#key statusKey}
                <LabeledEntity
                        id={statusKey}
                        label={$text(`prefab.server-status.label.${statusKey.replace(/_/g, "-")}`)}
                        content={status[statusKey]}
                        link={isLink(status[statusKey].toString())}
                />
            {/key}
        {/each}
    </div>
</Card>
