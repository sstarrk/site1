async function updateTime(){
	const time = new Date();
        document.querySelector('#current-time').textContent = time.toLocaleTimeString("ru-RU", {timeZone: 'Asia/Almaty'});
}

updateTime();
setInterval(updateTime, 1000);
