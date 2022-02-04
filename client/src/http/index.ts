import {get as sGet} from "svelte/store"
import {get, post} from 'axios';
import {AgentState} from "../state/agentState";

export const COMMAND_ROUTE='/api/command';
export const MANAGED_ROUTE='/api/managed';

export async function fetchStatus() {
    return get(`${COMMAND_ROUTE}/status`)
}

export async function fetchLogs() {
    return get(`${MANAGED_ROUTE}/logs`)
}

async function handleSendCommand(key: string, data?: any) {
    AgentState.set({
        ...sGet(AgentState),
        [key]: true
    })
    return post(`${COMMAND_ROUTE}/${key}`, data)
}

export async function sendStart() {
    return handleSendCommand('start')
}

export async function sendStop() {
    return handleSendCommand('stop')
}

export async function sendRestart() {
    return handleSendCommand('restart')
}

export async function sendUpdate(data) {
    return handleSendCommand(`update`, data)
}


export async function sendInstall() {
    return handleSendCommand('install')
}
