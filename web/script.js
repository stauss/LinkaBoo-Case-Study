function getCode() {
    var path = window.location.pathname;
    var match = path.match(/^\/r\/(.+)$/);
    return match ? decodeURIComponent(match[1]) : null;
}

function isValidCode(code) {
    return /^\d+-\w+-\w+$/.test(code);
}

function deepLinkFor(code) {
    return "linkaboo://receive/" + encodeURIComponent(code);
}

function showFallback() {
    document.getElementById("fallback").style.display = "block";
}

function copyCode() {
    var code = getCode();
    if (!code) return;

    navigator.clipboard.writeText(code).then(function () {
        document.getElementById("status-copy").textContent = "Code copied. Open LinkaBoo on your Mac and paste the code there if the handoff does not open automatically.";
    }).catch(function () {
        document.getElementById("status-copy").textContent = "Copy failed. Open LinkaBoo and enter the code shown on this page.";
    });
}

function attemptOpenApp() {
    var code = getCode();
    if (!code || !isValidCode(code)) {
        document.getElementById("main-card").style.display = "none";
        document.getElementById("error-card").style.display = "block";
        return;
    }

    var deepLink = deepLinkFor(code);
    document.getElementById("deep-link").href = deepLink;
    window.location = deepLink;

    setTimeout(function () {
        if (!document.hidden) {
            showFallback();
        }
    }, 1600);
}

// On page load, check if the code is valid.
(function () {
    var code = getCode();
    if (!code || !isValidCode(code)) {
        document.getElementById("main-card").style.display = "none";
        document.getElementById("error-card").style.display = "block";
        return;
    }

    document.getElementById("code-pill").textContent = code;
    document.getElementById("deep-link").href = deepLinkFor(code);
})();
