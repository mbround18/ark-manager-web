<script lang="ts">
    import Card from '../components/card.svelte'
    import ActionButton from '../components/action-button.svelte'
    import {text} from "../locale";
    import {post} from "axios";
</script>

<Card>
    <div class="pb-2">
        <p>
            {$text("prefab.server-actions.title")}
        </p>
        <hr class="bg-gray-900"/>
    </div>
    <div class="flex flex-col justify-items-stretch">
        <div>
            <ActionButton type="ok" onClick={async ()=> {
                post('/api/command/start')
            }}>{
                $text("prefab.server-actions.actions.start")
            }</ActionButton>
        </div>
        <div>
            <ActionButton type="err" onClick={async ()=> {
                post('/api/command/stop')
            }}>{
                $text("prefab.server-actions.actions.stop")
            }</ActionButton>
        </div>
        <div>
            <ActionButton type="warn" onClick={async ()=> {
                post('/api/command/restart')
            }}>{
                $text("prefab.server-actions.actions.restart")
            }</ActionButton>
        </div>
    </div>
</Card>
