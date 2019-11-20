<template>
  <div>
    <h1>{{ message }}</h1>
    <TabbedContent :tabs="tabbedData">
      <div>

      </div>
    </TabbedContent>
  </div>
</template>
<script lang="ts">
  import Vue from 'vue'
  import Component from 'vue-class-component'
  import {NODE_ENV} from "./config/environment";
  import Instances from "./components/instances.vue";
  import TabbedContent from "./components/tabbedContent.vue";
  import uuidv4 from 'uuid/v4';

  @Component({
    components: {TabbedContent, Instances}
  })
  export default class App extends Vue {
    data = {
      isInstances: false
    };
    tabbedData = [
      {id: uuidv4(), name: 'instances 1', childComponent: Instances},
      {id: uuidv4(), name: 'instances 2', childComponent: Instances}
    ];
    message: string = `Hello! You are running in ${NODE_ENV}!`;
  }
</script>
<style lang="sass">

</style>
