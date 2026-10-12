// Play looping research videos only while they are on screen.
// Videos start with preload="none" and a poster image, so nothing downloads
// until a clip scrolls into view. Visitors who prefer reduced motion get
// the poster and controls instead of autoplay.
(function () {
	var videos = document.querySelectorAll('video[data-autoplay]');
	if (!videos.length) return;

	var reduceMotion = window.matchMedia &&
		window.matchMedia('(prefers-reduced-motion: reduce)').matches;

	videos.forEach(function (v) {
		v.muted = true;
		v.setAttribute('playsinline', '');
	});

	if (reduceMotion || !('IntersectionObserver' in window)) return;

	var observer = new IntersectionObserver(function (entries) {
		entries.forEach(function (entry) {
			var v = entry.target;
			if (entry.isIntersecting) {
				if (v.preload === 'none') v.preload = 'auto';
				var p = v.play();
				if (p && p.catch) p.catch(function () {});
			} else if (!v.paused) {
				v.pause();
			}
		});
	}, { rootMargin: '200px 0px', threshold: 0.25 });

	videos.forEach(function (v) { observer.observe(v); });
})();
