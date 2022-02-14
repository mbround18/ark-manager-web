import {get as sGet} from "svelte/store"
// @ts-ignore
import axios, {AxiosResponse} from 'axios';
import {AgentState} from "../state/agentState";

export const COMMAND_ROUTE='/api/command';
export const MANAGED_ROUTE='/api/managed';

const {get, post} = axios;

export async function fetchStatus(): Promise<AxiosResponse> {
    return get(`${COMMAND_ROUTE}/status`)
}

export async function fetchLogs(): Promise<AxiosResponse> {
    return get(`${MANAGED_ROUTE}/logs`)
}

async function handleSendCommand(key: string, data?: any): Promise<AxiosResponse> {
    AgentState.set({
        ...sGet(AgentState),
        [key]: true
    })
    return post(`${COMMAND_ROUTE}/${key}`, data)
}

export async function sendStart(): Promise<AxiosResponse> {
    return handleSendCommand('start')
}

export async function sendStop(): Promise<AxiosResponse> {
    return handleSendCommand('stop')
}

export async function sendRestart(): Promise<AxiosResponse> {
    return handleSendCommand('restart')
}

export async function sendUpdate(data): Promise<AxiosResponse> {
    return handleSendCommand(`update`, data)
}


export async function sendInstall(): Promise<AxiosResponse> {
    return handleSendCommand('install')
}

export async function fetchConfigs(): Promise<AxiosResponse> {
    return get(`${MANAGED_ROUTE}/configs`)
}

export async function fetchConfig(path: string): Promise<AxiosResponse> {
    return get(`${MANAGED_ROUTE}/config`, { params: {path: encodeURIComponent(path)}})
}

export async function updateFile(path: string, content: string): Promise<AxiosResponse> {
    return post(`${MANAGED_ROUTE}/config`, content, {params: {path: encodeURIComponent(path)}})
}
