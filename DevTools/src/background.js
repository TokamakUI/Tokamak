chrome.runtime.onConnect.addListener((port) => {
    if (port.name !== 'content-script') {
        chrome.runtime.onMessage.addListener(function(msg, _, _) {
            port.postMessage(msg);
        });
        chrome.tabs.executeScript(+port.name, { file: 'content.js' });
    }
});
