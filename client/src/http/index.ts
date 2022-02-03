import {get, post} from 'axios';

const COMMAND_ROUTE='/api/command';
const MANAGED_ROUTE='/api/managed';

export async function fetchStatus() {
    return get(`${COMMAND_ROUTE}/status`)
}

export async function fetchState() {
    return get(`${MANAGED_ROUTE}/status`)
}

export async function fetchLogs() {
    return get(`${MANAGED_ROUTE}/logs`)
}

export async function sendStart() {
    return post(`${COMMAND_ROUTE}/start`)
}

export async function sendStop() {
    return post(`${COMMAND_ROUTE}/stop`)
}

export async function sendRestart() {
    return post(`${COMMAND_ROUTE}/restart`)
}

export async function sendUpdate(data) {
    return post(`${COMMAND_ROUTE}/update`, data)
}


export async function sendInstall() {
    return post(`${COMMAND_ROUTE}/install`)
}
