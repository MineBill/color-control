const light_theme_options = document.getElementById("light-theme");
const dark_theme_options = document.getElementById("dark-theme");

function populateThemeOptions() {
    browser.management.getAll().then((extensions) => {
        for (const ext of extensions) {
            if (ext.type == "theme") {
                let option = document.createElement("option")
                option.text = ext.name;
                option.value = ext.id;
                option.classList.add("browser-style");
                light_theme_options.appendChild(option.cloneNode(true));
                dark_theme_options.appendChild(option.cloneNode(true));
            }
        }
    })
}

function saveOptions(e) {
    let light_theme_id = light_theme_options.options[light_theme_options.selectedIndex].value;
    let dark_theme_id = dark_theme_options.options[dark_theme_options.selectedIndex].value;
    browser.storage.sync.set({
        light_theme: light_theme_id,
        dark_theme: dark_theme_id,
    })
    e.preventDefault();
}

document.addEventListener('DOMContentLoaded', () => {
    populateThemeOptions();
});

document.querySelector("form").addEventListener("submit", (e) => {
    saveOptions(e);
});
