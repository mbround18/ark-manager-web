import Vue from "vue";
import Vuex from 'vuex';
import axios from 'axios';
import {DispatchType} from "./utils/types";
import {API_HOST} from "./config/environment";
import {Map} from 'immutable';

Vue.use(Vuex);

const state: any = {
    instances: [],
    count: 0
};
const mutations: any = {
    increment(state: any) {
        state.count++
    },
    setInstances(state: any, payload: any) {
        console.log('setting intances');
        state.instances = payload;
    }
};
const actions: any = {
    increment ({ commit }: DispatchType) {
        commit('increment');
    },
    fetchInstances({ commit }: DispatchType) {
        console.log('dispatching', 'fetchInstances');
        axios.get(`http://${API_HOST}/api/v1/instances`).then((response) => {
            const instances = response.data.map((instanceData: any) => Map(instanceData));
            console.log('data fetched', instances);
            commit('setInstances', instances);
        });
    }
};
/**
 * const moduleA = {
 *   state: { ... },
 *   mutations: { ... },
 *   actions: { ... },
 *   getters: { ... }
 * }
 */
export const store = new Vuex.Store({
    state,
    mutations,
    actions
});


// @ts-ignore
if (module.hot) {
    // Promise.all([import('./mutations')]).then(([mutations]) => {
        // @ts-ignore
        module.hot.accept([], () => {
            // require the updated modules
            // have to add .default here due to babel 6 module output
            // swap in the new modules and mutations
            store.hotUpdate({
                mutations
            })
        })
    // });
}
