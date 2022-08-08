let port = browser.runtime.connectNative("color_control_middleman");

port.onMessage.addListener((response) => {
    console.log("Received message: " + response.mode);
    switch (response.mode) {
        case "dark": {
            browser.storage.sync.get("dark_theme").then((theme) => {
                browser.management.setEnabled(theme.dark_theme, true);
                browser.browserSettings.overrideContentColorScheme.set({
                    value: "dark"
                })
            })
            break;
        }
        case "light": {
            browser.storage.sync.get("light_theme").then((theme) => {
                browser.management.setEnabled(theme.light_theme, true);
                browser.browserSettings.overrideContentColorScheme.set({
                    value: "light"
                })
            })
            break;
        }
    }
});
