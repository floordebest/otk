function loginWithChainWeaver(login) {
    if (!login) {
        document.getElementById("enterPrivKey").style.display = "none"
    } else {
        document.getElementById("enterPrivKey").style.display = "contents"
    }
}

function checkStorage() {
    var account = localStorage.getItem("accountName")
    console.log(account)
    if (!account) {
        document.getElementById("loginPage").style.display = "contents"
        document.getElementById("enterPrivKey").style.display = "none";
        document.getElementById("loggedIn").style.display = "none";
    } else {
        document.getElementById("loginPage").style.display = "none"
        document.getElementById("loggedIn").style.display = "contents";
        getOTKAds();
    }
}

