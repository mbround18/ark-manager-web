<script lang="ts">
    import Card from "../components/card.svelte";
    import ActionButton from "../components/action-button.svelte";
    import Tooltip from "../components/tooltip.svelte";
    import {text} from "../locale";
    import {onMount, onDestroy} from "svelte";
    import {Settings} from "../assets/icons";
    import {sendUpdate} from "../http";

    let showOptions = false;
    const localStorageKey = "server-updater-options";
    let options = [
        {
            id: "warn",
            state: true
        },
        {
            id: "force",
            state: false
        },
        {
            id:"validate",
            state: false
        },
        {
            id: "save_world",
            state: true
        },
        {
            id: "update_mods",
            state: true
        },
        {
            id: "backup",
            state: true
        }
    ]

    function loadOptions() {
        try {
            const prevOptions = localStorage.getItem(localStorageKey) || "";
            options = [
                ...JSON.parse(window.atob(prevOptions))
            ]
        } catch (e) {
            storeOptions();
        }
    }

    function storeOptions() {
        localStorage.setItem(
            localStorageKey,
            window.btoa(JSON.stringify(options))
        )
    }

    onMount(() => {
        loadOptions();
        options = options.map(entity => {
            return {
                ...entity,
                name: $text(`prefab.update-server.option.${entity.id}.name`),
                desc: $text(`prefab.update-server.option.${entity.id}.desc`)
            }
        })
    });
    onDestroy(storeOptions)

    async function handleLaunchUpdate() {
        storeOptions();
        const data = options.reduce((acc, {id, state})=> {
            acc[id] = state;
            return acc;
        },{})
        await sendUpdate(data)
    }

</script>

<Card>
    <div class="pb-2">
        <p>
            {$text("prefab.update-server.title")}
        </p>
        <hr class="bg-gray-900"/>
    </div>
    <table class="table-auto" class:hidden={!showOptions}>
        <thead>
            <tr>
                <th></th>
                <th>Option</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            {#each options as {name, desc, state, id}}
            <tr class="divide-x-1">
                <td class="pr-2">
                    <input
                            type="checkbox"
                            bind:checked={state}
                            on:click={storeOptions}
                            {name}
                            {id}
                    >
                </td>
                <td
                        class:text-red-500={id === "force"}
                >{name}</td>
                <td
                        class:text-red-500={id === "force"}
                >{desc}</td>
            </tr>
            {/each}
        </tbody>
    </table>
    <div class:hidden={showOptions}>
        <p>{$text("prefab.update-server.label.options")}</p>
        <ul>
            {#each options as {id, name, state}}
                {#if state}
                    <li
                            class:text-red-500={id === "force"}
                    >- {name}</li>
                {/if}
            {/each}
        </ul>
    </div>
    <div class="flex flex-row place-items-stretch pt-4">
        <ActionButton
                type="primary"
                classNames="grow pr-4 pl-4"
                onClick={()=> handleLaunchUpdate()}
        >
            {$text("prefab.update-server.actions.update")}
        </ActionButton>
        <Tooltip
                tooltip={$text("prefab.update-server.actions.options", {values: {
                    visibility: !showOptions ? $text("global.show") : $text("global.hide")
                }})}
        >
            <img class="invert" src={Settings} alt="Settings" on:click={()=> showOptions = !showOptions}>
        </Tooltip>

    </div>
</Card>
