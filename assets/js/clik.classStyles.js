/**
 * Class-style fallback and test-page style switcher.
 *
 * In class mode, custom properties used by Clik's style queries are reflected
 * as `clik-{property}-{value}` classes on the same component container.
 */
(function () {
	"use strict";

	const stylesheetTypes = [
		"columns", "forms", "grids", "images", "items", "menus", "navbuttons", "tabs"
	];
	const settings = [
		{ selector: "body", properties: ["header-fixed", "headerpos", "footer-fixed", "menupos", "site-align", "framed", "xcol", "menu"] },
		{ selector: "#xcol", properties: ["sticky"] },
		{ selector: "#menu", properties: ["sticky"] },
		{ selector: "form", properties: ["field-layout", "checkbox-replace"] },
		{ selector: ".grid", properties: ["grid-mode", "caption-position", "justify-frame"] },
		{ selector: ".cs-image", properties: ["height-fix"] },
		{ selector: ".item", properties: ["htop", "image-align", "texttop", "show-title", "show-image", "imagespace", "wrap"] },
		{ selector: ".menu", properties: ["menu-mode", "menu-align", "menu-reverse", "menu-orientation", "menu-stretch", "menu-borders", "menu-submenu-show", "menu-submenualign", "menu-submenu-position", "menu-rollout"] },
		{ selector: ".button", properties: ["icon-display", "label-display", "button-align", "popout"] },
		{ selector: ".cs-tabs", properties: ["vertical", "accordian"] }
	];

	function slug(value) {
		return value.trim().replace(/^['"]|['"]$/g, "").toLowerCase()
			.replace(/[^a-z0-9_-]+/g, "-").replace(/^-+|-+$/g, "");
	}

	function reflectedClass(property, value) {
		return `clik-${property}-${slug(value)}`;
	}

	function reflectElement(element, properties) {
		const computed = getComputedStyle(element);
		const desired = properties.map(function (property) {
			const value = computed.getPropertyValue(`--${property}`);
			return value.trim() ? reflectedClass(property, value) : null;
		}).filter(Boolean);
		const prefixes = properties.map(function (property) { return `clik-${property}-`; });
		const existing = Array.from(element.classList).filter(function (className) {
			return prefixes.some(function (prefix) { return className.startsWith(prefix); });
		});
		if (existing.length === desired.length && existing.every(function (name) { return desired.includes(name); })) {
			return;
		}
		existing.forEach(function (name) { element.classList.remove(name); });
		desired.forEach(function (name) { element.classList.add(name); });
	}

	function reflectAll() {
		settings.forEach(function (entry) {
			document.querySelectorAll(entry.selector).forEach(function (element) {
				reflectElement(element, entry.properties);
			});
		});
	}

	function selectedMode() {
		return new URLSearchParams(location.search).get("clik-style") === "classes" ? "classes" : "container";
	}

	function switchStylesheets() {
		if (selectedMode() !== "classes") return;
		document.querySelectorAll('link[rel~="stylesheet"][href]').forEach(function (link) {
			const url = new URL(link.href, document.baseURI);
			const match = url.pathname.match(/\/([^/]+)\.css$/);
			if (!match || !stylesheetTypes.includes(match[1])) return;
			url.pathname = url.pathname.replace(/\.css$/, "_classes.css");
			link.href = url.href;
		});
	}

	function modeUrl(mode) {
		const url = new URL(location.href);
		if (mode === "classes") url.searchParams.set("clik-style", "classes");
		else url.searchParams.delete("clik-style");
		return url.href;
	}

	function makeSwitcherDraggable(switcher) {
		const handle = switcher.querySelector("strong");
		let drag = null;
		handle.style.cursor = "grab";
		handle.style.touchAction = "none";
		handle.style.userSelect = "none";
		handle.title = "Drag CSS mode switcher";
		handle.addEventListener("pointerdown", function (event) {
			if (event.button !== 0) return;
			const rect = switcher.getBoundingClientRect();
			drag = { id: event.pointerId, x: event.clientX, y: event.clientY, left: rect.left, top: rect.top };
			handle.setPointerCapture(event.pointerId);
		});
		handle.addEventListener("pointermove", function (event) {
			if (!drag || event.pointerId !== drag.id) return;
			const rect = switcher.getBoundingClientRect();
			switcher.style.left = Math.max(0, Math.min(innerWidth - rect.width, drag.left + event.clientX - drag.x)) + "px";
			switcher.style.top = Math.max(0, Math.min(innerHeight - rect.height, drag.top + event.clientY - drag.y)) + "px";
			switcher.style.right = "auto";
			event.preventDefault();
		});
		function stop(event) {
			if (!drag || event.pointerId !== drag.id) return;
			drag = null;
			if (handle.hasPointerCapture(event.pointerId)) handle.releasePointerCapture(event.pointerId);
		}
		handle.addEventListener("pointerup", stop);
		handle.addEventListener("pointercancel", stop);
		handle.addEventListener("lostpointercapture", stop);
	}

	function addSwitcher() {
		const current = selectedMode();
		const switcher = document.createElement("nav");
		switcher.className = "clik-style-switcher";
		switcher.setAttribute("aria-label", "CSS implementation");
		switcher.innerHTML = `<strong>&#9881; CSS mode</strong><a href="${modeUrl("container")}">Container</a><a href="${modeUrl("classes")}">Classes</a>`;
		switcher.querySelectorAll("a")[current === "classes" ? 1 : 0].setAttribute("aria-current", "page");
		const style = document.createElement("style");
		style.textContent = ".clik-style-switcher{position:fixed;z-index:2147483647;right:8px;top:8px;display:flex;gap:6px;align-items:center;padding:7px 9px;border:1px solid #555;border-radius:5px;background:#fff;color:#222;font:12px/1.2 sans-serif;box-shadow:0 2px 8px #0005;opacity:.3;transition:opacity .15s}.clik-style-switcher:hover,.clik-style-switcher:focus-within{opacity:1}.clik-style-switcher a{color:#0645ad}.clik-style-switcher a[aria-current=page]{font-weight:bold;text-decoration:none;color:#222}";
		document.head.appendChild(style);
		document.body.appendChild(switcher);
		makeSwitcherDraggable(switcher);
	}

	switchStylesheets();
	document.addEventListener("DOMContentLoaded", function () {
		addSwitcher();
		if (selectedMode() !== "classes") return;
		let queued = false;
		const scheduleReflection = function () {
			if (queued) return;
			queued = true;
			requestAnimationFrame(function () {
				queued = false;
				reflectAll();
			});
		};
		reflectAll();
		// Swapped stylesheets may finish loading after DOMContentLoaded. Their
		// @property initial values must be available before reflecting defaults.
		document.addEventListener("load", function (event) {
			if (event.target.matches && event.target.matches('link[rel~="stylesheet"]')) {
				scheduleReflection();
			}
		}, true);
		window.addEventListener("resize", scheduleReflection);
		new MutationObserver(scheduleReflection).observe(document.body, {
			attributes: true,
			attributeFilter: ["class", "style"],
			childList: true,
			subtree: true
		});
	});
})();
