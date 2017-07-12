function submitForm(frm) {
    var values = {
        assetTag: frm.assetTag.value,
        computerName: frm.computerName.value
    };
    window.webkit.messageHandlers.splashbuddy.postMessage(JSON.stringify(values));
}


