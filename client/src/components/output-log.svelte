<script lang="ts">
    import {afterUpdate, onMount, onDestroy} from "svelte"
    import ActionButton from "./action-button.svelte"
    import Tooltip from "./tooltip.svelte"
    import {encode} from "js-base64"
    import {Lock, Unlock} from "../assets/icons";
    import {get} from "axios";
    import {padEnd, padStart} from "lodash";

    export let source: string;
    let stream;
    let logs = [];

    function parseLogMessage(message: string): { time: number; message: string, namespace: string } {
        try {
            const {content, namespace, timestamp} = JSON.parse(message);
            return {
                message: content,
                namespace,
                time: timestamp
            }
        } catch (_e) {
            return {
                message,
                namespace: "unknown",
                time: Date.now()
            }
        }
    }

    function updateLogs(
        {
            message,
            namespace,
            time
        }
    ) {
        logs = [...logs, {
            message, namespace, time
        }]
    }

    function initializeStream() {
        stream = new EventSource(`/api/command/tail?log=${encodeURIComponent(source)}`)
        stream.onmessage = ({data}) => {
            const  {message: logMessage} = JSON.parse(data);
            let {time, message, namespace} = parseLogMessage(logMessage)
            updateLogs({
                message, namespace, time
            })
        }
    }
    onMount(async ()=>{
        const {data} = await get(`/api/managed/log?path=${encodeURIComponent(source)}`)
        data
            .filter(e => (e?.length || 0) > 0)
            .forEach(logMessage => {
            const {time, message, namespace} = parseLogMessage(logMessage);
            updateLogs({ message, namespace, time})
        })
        initializeStream()
    })

    onDestroy(()=> {
        stream.close()
    })

    let scrollLocked = true;
    let unorderedList;

    afterUpdate(() => {
        if (scrollLocked) {
            unorderedList.scrollTop = unorderedList.scrollHeight;
        }
    })

    function createId(action: {time: number, message: string}, index: number) {
        return encode([
            action.time,
            action.message,
            index
        ].join('-'))
    }
</script>

<div class="container">
    <div class="w-fit relative float-right hidden show-on-hover ml-2">
        <ActionButton
                type="none"
                onClick={()=> scrollLocked = !scrollLocked}
        >
            <Tooltip
                    tooltip={`Click to ${scrollLocked ? "Disable" : "Enable"} Auto Scroll`}
            >
                <img class="invert" src={scrollLocked ? Lock : Unlock} alt={scrollLocked ? "Unlock" : "Lock"}/>
            </Tooltip>
        </ActionButton>
    </div>
    <div
            class="overflow-auto h-96"
            bind:this={unorderedList}
            class:overflow-y-hidden={scrollLocked}
    >
    <table
            class="text-sm w-fit text-justify"
    >
        <thead>
            <tr>
                <th>Timestamp</th>
                <th>Namespace</th>
                <th>Log Message</th>
            </tr>
        </thead>
        <tbody>
            {#each logs as {time, message, namespace}, index}
                {#key createId({time, message}, index)}
                    <tr>
                        <td class="text-purple-400 pr-2">{
                            time
                        }</td>
                        <td class="text-green-400 pr-2">{
                            namespace
                        }</td>
                        <td>{message}</td>
                    </tr>
                {/key}
            {/each}
        </tbody>
    </table>
    </div>
</div>

<style lang="scss">
  .container {
    tbody {
      @apply pt-4;
    }
    table, tr {
      padding: 0;
      margin: 0;
    }
    th {
      @apply bg-gray-700 pb-2;
      position: sticky;
      top: 0;
      box-shadow: 0 2px 2px -1px rgba(0, 0, 0, 0.4);
    }
  }
  .container:hover {
    .show-on-hover {
      display: block;
    }
  }
</style>
