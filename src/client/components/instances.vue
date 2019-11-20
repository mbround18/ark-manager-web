<template>
    <div>
        <h2>instances</h2>
        <button v-on:click="setInstances" >refresh</button>
        <ul v-if="!!instances.length">
            <li v-for="item of instances" :key="item.id">
                {{item.get('name')}}
            </li>
        </ul>
    </div>
</template>

<script lang="ts">
    import Vue from 'vue'
    import Component from 'vue-class-component'
    import {store} from "../store";

    @Component
    export default class Instances extends Vue {
        get instances() {
            return store.state.instances;
        }
        getInstances() {
            store.dispatch('fetchInstances');
        }
        mounted() {
            this.getInstances();
        }
    }
</script>

<style scoped lang="sass">

</style>