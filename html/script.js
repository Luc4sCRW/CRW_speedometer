window.addEventListener('message', function(event) {
    const data = event.data;
    const container = document.getElementById('speedo-container');

    if (data.type === "updateVehicleHud") {
        if (data.show) {
            container.style.display = "flex";
            container.style.opacity = "1";

            // Speed
            document.getElementById('speed').innerText = Math.floor(data.speed).toString().padStart(3, '0');

            // RPM
            const rpmPercent = data.rpm * 100;
            const rpmBar = document.getElementById('rpm-bar');
            rpmBar.style.width = rpmPercent + "%";
            if (rpmPercent > 85) {
                rpmBar.classList.add('redline');
            } else {
                rpmBar.classList.remove('redline');
            }

            // Fuelbar
            document.getElementById('fuel-bar').style.width = data.fuel + "%";

            // Gearbopx
            let gear = data.gear;
            const gearElement = document.getElementById('gear');
            if (gear === 0) {
                gearElement.innerText = "R";
                gearElement.style.color = "#ff3131";
            } else if (gear === 1 && data.speed < 2) {
                gearElement.innerText = "N";
                gearElement.style.color = "#fff";
            } else {
                gearElement.innerText = gear;
                gearElement.style.color = "#fff";
            }
        } else {
            container.style.opacity = "0";
            setTimeout(() => { container.style.display = "none"; }, 300);
        }
    }
});
