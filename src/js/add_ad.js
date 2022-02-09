function sellAccountOrToken(value) {
    if (!value) {
        document.getElementById("sellAccountForm").style.display = "none";
    } else {
        document.getElementById("sellTokenForm").style.display = "contents";
    }
}

function loadNewAd() {
    document.getElementById("sellTokenForm").style.display = "none";
}