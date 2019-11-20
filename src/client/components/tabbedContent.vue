<template>
    <div class="tabbed-content">
        <div
                :key="tabInfo.id + '-tab'"
                v-for="tabInfo of tabNames"
                v-on:click="setCurrentId(tabInfo.id)"
                v-bind:class="{ ['tab']: true, active: currentId === tabInfo.id }"
        >
            <h3>{{tabInfo.name}}</h3>
        </div>
        <div v-for="tabElement of tabElements" :key="tabElement.id + '-ele'">
            <component v-bind:is="tabElement.childComponent"></component>
        </div>
    </div>
</template>

<script lang="ts">
    import Vue, {PropOptions} from 'vue'
    import Component from 'vue-class-component'
    type TabData = {
        id: string,
        name: string
        childComponent: Vue
    }
    @Component({
        props: {
            tabs: <PropOptions<TabData[]>>{}
        }
    })
    export default class TabbedContent extends Vue {
        tabs!: TabData[];

        set currentId (id: any) {
            this.currentId = id;
        }
        get tabNames() {
           return this.tabs.map(({id, name}: TabData) => ({id, name}))
        }
        get tabElements() {
            return this.tabs.map(({id, childComponent}: TabData) => ({id, childComponent}))
        }
    }
</script>

<style scoped lang="sass">


</style>