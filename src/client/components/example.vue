<template>
    <div>
      example
    </div>
</template>

<script lang="ts">
    import Vue from 'vue'
    import Component from 'vue-class-component'
    import {store} from "../store";

    @Component
    export default class Instances extends Vue {
        instances: any[] = [];
        setInstances() {
            store.dispatch('fetchInstances').then(()=> {
                if( this.instances !== store.state.instances) {
                    this.instances = store.state.instances
                }
            });
        }
        created() {
            this.setInstances();
        }
    }
</script>

<style scoped lang="sass">

</style>