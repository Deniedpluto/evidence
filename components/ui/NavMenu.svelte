<script>
    import { onMount } from 'svelte';
    import navConfig from './nav-menu-config.json';
    export let data;

    let pages = [];
    let isOpen = true;
    let isMobile = false;

    const checkMobile = () => {
        isMobile = window.matchMedia('(max-width: 768px)').matches;
        isOpen = isMobile ? false : true;
    };

    onMount(() => {
        checkMobile();
        if (data && data.pagesManifest && data.pagesManifest.children) {
            const { label } = data.pagesManifest;
            const homePage = { label : label.toLowerCase(), href : '', show: true, children : [] };
            let pagesData = [ homePage,  ...Object.values(data.pagesManifest.children) ];

            let sortedPages = pagesData
                .filter(page => navConfig.find(cfg => cfg.label === page.label))
                .map(page => ({...page, children : Object.values(page.children),  ...navConfig.find(cfg => cfg.label === page.label)}))
                .filter(page => page.show !== false) 
                .sort((a, b) => a.order - b.order);
          
            pages = [...sortedPages,];
        } else {
            console.error('No pages data');
        }
    });

    function capitalizeFirstLetter(string) {
        if (!string) return string;
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    function handleNavigation() {

        if(isMobile) {
            isOpen = false;
        }

    }

</script>

{#if pages && pages.length > 0}
  

<div class="flex">
    
    <div class={`bg-gray-800 text-white w-64 min-h-screen ${isOpen ? 'block' : 'hidden'} transition-all`}>
      <div class="p-4 flex justify-between">
        <h5 class="text-2xl font-semibold"><a href="/">Evi Dashboard</a></h5>
        <button on:click={() => isOpen = !isOpen}>
            <img class="cursor-pointer" src="/imgs/close.svg" alt="menu" width="20" height="20">
        </button>
        
      </div>
      <ul>
        {#each pages as item}
              {#if item.children.length === 0}
                  <li class="hover:bg-gray-700 p-3"><a href="{item.href}/" on:click={handleNavigation}>{capitalizeFirstLetter(item.label)}</a></li>
              {/if}
              {#if item.children.length > 0}
                  <li>
                      <a href>{capitalizeFirstLetter(item.label)} <span uk-nav-parent-icon></span></a>
                      <ul>
                          {#each item.children as child}
                              {#if child.label}
                                  <li><a href={child.href}>{capitalizeFirstLetter(child.label)}</a></li>
                                  <li class="hover:bg-gray-700 p-3"><a href={child.href} on:click={handleNavigation}>{capitalizeFirstLetter(child.label)}</a></li>
                              {/if}
                          {/each}
                      </ul>
                  </li>
              {/if}
          {/each}
      </ul>
    </div>
  
    
    <div class={`flex-1 ${isOpen ? 'open-sidenav' : 'close-sidenav'}`}>
        <button on:click={() => isOpen = !isOpen} class="relative top-14 left-11">
            <img class="cursor-pointer" src="/imgs/burger-menu.svg" alt="menu" width="20" height="20">
        </button>
        <slot/>
    </div>

  </div>

{/if}

<style>

.open-sidenav {
    width: calc(100% - 16rem);
}

.close-sidenav {
    width: 100%;
}

</style>