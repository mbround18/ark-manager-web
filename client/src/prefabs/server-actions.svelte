<script lang="ts">
    import Card from '../components/card.svelte'
    import ActionButton from '../components/action-button.svelte'
    import {text} from "../locale";
    import {onMount} from "svelte";
    import {sendInstall, sendRestart, sendStart, sendStop} from "../http";
    import {AgentState} from "../state/agentState";

    let installed = false;

    onMount(async ()=> {
        const {installed: installable} = await  import("../state/installed");
        // @ts-ignore
        await installable.subscribe((v) => installed = v);
    })
</script>

<Card>
    <div class="pb-2">
        <p>
            {$text("prefab.server-actions.title")}
        </p>
        <hr class="bg-gray-900"/>
    </div>
    <div class="flex flex-col justify-items-stretch">
        {#if installed}
            <div>
                <ActionButton
                    type="ok"
                    onClick={async ()=> sendStart()}
                    disabled={$AgentState.start}
                >{
                    $text("prefab.server-actions.actions.start")
                }</ActionButton>
            </div>
            <div>
                <ActionButton
                    type="err"
                    onClick={async ()=> sendStop()}
                    disabled={$AgentState.stop}
                >{
                    $text("prefab.server-actions.actions.stop")
                }</ActionButton>
            </div>
            <div>
                <ActionButton
                    type="warn"
                    onClick={async ()=> sendRestart()}
                    disabled={$AgentState.stop}
                >{
                    $text("prefab.server-actions.actions.restart")
                }</ActionButton>
            </div>
        {:else}
            <div>
                <ActionButton
                    type="primary"
                    onClick={async ()=> sendInstall()}
                    disabled={$AgentState.install}
                >{
                    $text("prefab.server-actions.actions.install")
                }</ActionButton>
            </div>
        {/if}
    </div>
</Card>
