import Vue from 'vue';
import App from './app.vue';


// @ts-ignore
if (module.hot) module.hot.accept();

new Vue({
    el: '#root',
    render: h => h(App)
});