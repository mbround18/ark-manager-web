<script lang="ts">
    import Card from "../components/card.svelte";
    import ActionButton from "../components/action-button.svelte";
</script>

<Card>
    <div>
        <p>Mod Manager</p>
        <hr class="pb-4" />
    </div>
    <div>
        <table class="table table-auto">
            <thead>
                <tr>
                    <th>
                        Mod ID
                    </th>
                    <th>
                        Name
                    </th>
                    <th>
                    </th>
                    <th>
                    </th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>1111111</td>
                    <td>Base Mod</td>
                    <td>
                        <ActionButton>
                            Enable
                        </ActionButton>
                    </td>
                    <td>
                        <ActionButton type="err">
                            Remove
                        </ActionButton>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</Card>

<style lang="scss">
    td {
      @apply pr-4;
    }
</style>
