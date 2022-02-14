<script lang="ts">
    import {CodeJar} from "codejar/codejar";
    import {withLineNumbers} from 'codejar/linenumbers';
    import {get, last} from "lodash";
    import Card from '../components/card.svelte';
    import ActionButton from '../components/action-button.svelte';
    import {onMount} from "svelte";
    import {text} from "../locale";
    import {fetchConfig, fetchConfigs, updateFile} from "../http";
    // Elements
    let jar: CodeJar;
    let editor;
    let Prism: {[key: string]: any} = get(window, "Prism")

    // Switches
    let hasFetched = false;
    let beenSaved = false;
    let notFound = false

    // Data
    let files = [];
    let selectedFile = "";

    // Defaults
    const baseContent = $text('prefab.configuration-management.initial-content');
    const emptyFile = `\n${"\t".repeat(6)}`.repeat(10);

    // Code
    onMount(async () => {
        jar = CodeJar(editor, withLineNumbers(Prism.highlightElement), {history: false});
        jar.updateCode(baseContent)
        fetchConfigs().then(({data})=> {
            files = data.map(path=> ({
                path,
                name: last(path.split('/'))
            }))
            hasFetched = true;
        })
    })

    async function openFile(name: string, path: string) {
        try {
            const {data, status} = await fetchConfig(path);
            if (status === 200) {
                notFound = false;
                if (data === "\n") {
                    jar.updateCode(emptyFile)
                } else {
                    jar.updateCode(data)
                }
                selectedFile = name;
            } else {
                console.error(data)
            }
        } catch (e) {
            notFound = e.response.status === 404
            console.error(e)
        }

    }

    async function closeFile(save: boolean) {
        const file = files.find(({name})=> name === selectedFile);
        if (file) {
            if (save) {
                const {path} = file;
                await updateFile(path, jar.toString())
                beenSaved = true;
            } else {
                selectedFile = "";
                jar.updateCode(baseContent)
            }

        }
    }
</script>

<Card classNames={hasFetched ? "" : "hidden"}>
    <div class="flex flex-row">
        <div>
            {#if selectedFile}
                <p>{$text("prefab.configuration-management.label.editing", {values: {
                        file: selectedFile
                }})}</p>
                <ActionButton type="secondary" onClick={()=> closeFile(true)}>
                    {$text("prefab.configuration-management.action.save")}
                </ActionButton>
                <ActionButton type="primary" onClick={()=> closeFile(false)}>
                    {$text("prefab.configuration-management.action.close")}
                </ActionButton>
            {:else}
                {#each files as {path, name}}
                    <ActionButton onClick={()=> openFile(name, path)}>
                        {$text("prefab.configuration-management.label.edit", {values: {file: name}})}
                    </ActionButton>
                {/each}

            {/if}
        </div>
        <div class="pl-8">
            <div bind:this={editor} id="editor" class="language-ini"></div>
            {#if notFound}
                <p class="text-red-700">{
                    $text("prefab.configuration-management.errors.not-found", {values: { file: selectedFile }})
                }</p>
            {/if}
            {#if selectedFile}
                <p class:hidden={!beenSaved}>{$text("prefab.configuration-management.label.saved", {values: {
                        file: selectedFile,
                        time: new Date(Date.now()).toISOString()
                }})}</p>
            {/if}
        </div>
    </div>
    <div>
        <a href="https://ini.arkforum.de/index.php?lang=en&mode=all" target="_blank">
            {$text("prefab.configuration-management.links.config-generator")}
        </a>
    </div>
</Card>

<style lang="scss">
  a {
    @apply text-blue-500;
    &:visited {
      @apply text-violet-400;
    }
  }
  #editor {
    @apply max-w-7xl max-h-96;
    border-radius: 6px;
    box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.14), 0 1px 5px 0 rgba(0, 0, 0, 0.12), 0 3px 1px -2px rgba(0, 0, 0, 0.2);
    font-family: 'Source Code Pro', monospace;
    font-size: 14px;
    font-weight: 400;
    letter-spacing: normal;
    line-height: 20px;
    padding: 10px;
    tab-size: 4;
  }
</style>
