<script>
    export let classNames=$$props.class
    export let id=$$props.id
    export let center = true;
</script>



<div
        {id}
        class={["rounded bg-gray-700 p-4", classNames].join(" ")}
        class:place-self-center={center}
>
    <slot />
</div>
