document.body.addEventListener('_tokamak_debug_tree_update', (e) => {
    chrome.runtime.sendMessage({ updates: e.detail }, null);
});
