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
        
        // This code updates the folder group to use the title instead of the folder name
        /* sortedPages = sortedPages.map(page => {
            // page.label = page.title;
            // This will update the child pages somehow...
            page.children = page.children.map(child => {
                child.href = child.href;
                child.label = child.title;
                return child;
            });
            return page;
        })  */              

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

    // Added this section in to handle the collapsing of the side nav menu.
    let openParent = null; // Track which parent is open

    function toggleParent(idx) {
        openParent = openParent === idx ? null : idx;
    }

</script>

{#if pages && pages.length > 0}
  

<div class="flex">
    
    <div class={`bg-gray-800 text-white w-64 min-h-screen ${isOpen ? 'block' : 'hidden'} transition-all`}>
      <div class="p-4 flex justify-between">
        <h5 class="text-2xl font-semibold"><a href="/">Nav Menu</a></h5>
        <button on:click={() => isOpen = !isOpen}>
            <img class="cursor-pointer" src="/imgs/close.svg" alt="menu" width="20" height="20">
        </button>
        
      </div>

    <!-- This is the section that handles the collapsing of the side nav menu. -->
    <ul>
        {#each pages as item, idx}
            {#if item.children.length === 0}
                <li class="hover:bg-gray-700 p-3">
                    <a href="{item.href}/" on:click={handleNavigation}>
                        {capitalizeFirstLetter(item.label)}
                    </a>
                </li>
            {/if}
            {#if item.children.length > 0}
                <li>
                    <button
                        class="w-full text-left p-3 hover:bg-gray-700 flex items-center"
                        on:click={() => toggleParent(idx)}
                    >
                        {capitalizeFirstLetter(item.title)}
                        <span class="ml-auto">{openParent === idx ? '▲' : '▼'}</span>
                    </button>
                    {#if openParent === idx}
                        <ul class="nested-list">
                            {#each item.children as child}
                                <li class="hover:bg-gray-700 p-3">
                                    <a href="{child.href}/" on:click={handleNavigation}>
                                        {capitalizeFirstLetter(child.title)}
                                    </a>
                                </li>
                            {/each}
                        </ul>
                    {/if}
                </li>
            {/if}
        {/each}
    </ul>

      <!-- This was replaced with the above section for collapsing the side nav menu.
      <ul>
        {#each pages as item}
              {#if item.children.length === 0}
                  <li class="hover:bg-gray-700 p-3"><a href="{item.href}/" on:click={handleNavigation}>{capitalizeFirstLetter(item.label)}</a></li>
              {/if}
              {#if item.children.length > 0}
                  <li style="padding-left: 1em">
                    <a href>{capitalizeFirstLetter(item.title)} <span uk-nav-parent-icon></span></a>
                    <ul>
                          {#each item.children as child}
                              {#if child.label}
                                  <li class="hover:bg-gray-700 p-3"><a href="{child.href}/" on:click={handleNavigation}>{capitalizeFirstLetter(child.title)}</a></li>
                              {/if}
                          {/each}
                      </ul>
                  </li>
              {/if}
          {/each}
      </ul>
    -->
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