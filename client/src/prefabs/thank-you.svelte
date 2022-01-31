<script lang="ts">
    import {text} from "../locale";
    import Card from '../components/card.svelte'
</script>

<svelte:head>
    <title>{$text("app.title")}</title>
</svelte:head>

<Card>
    <h1 class="text-white">{$text("app.title")}</h1>
    <p>{$text("app.thank-you")}</p>
</Card>
