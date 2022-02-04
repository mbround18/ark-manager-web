import {get} from "axios";
import {writable} from "svelte/store"
import {MANAGED_ROUTE} from "../http";

export const AgentState = writable({
    start: false,
    stop: false,
    restart: false,
    update: false,
    install: false,
})

export async function fetchState() {
    const {data} = await get(`${MANAGED_ROUTE}/state`)
    await AgentState.set(data);
}
