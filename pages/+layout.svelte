
<script>
    import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	export let data;

	import "$lib/css/style.css";

	import NavMenu from "$lib/ui/NavMenu.svelte";
</script>


<svelte:head>
	<title>DeniedPluto's Big Page of Little Data</title>
</svelte:head>


<NavMenu {data} > 

	<EvidenceDefaultLayout {data}
	logo="/imgs/logo.svg"
	title='Evidence Test App'
  	neverShowQueries={true}
  	githubRepo='https://github.com/deniedpluto/evidence'
  	hideSidebar={true}
  	fullWidth={true}
	hideTOC={false}
	>
	
	<slot slot="content"/>

</EvidenceDefaultLayout>


</NavMenu>
