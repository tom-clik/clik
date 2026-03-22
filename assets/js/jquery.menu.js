/**
 * jQuery menu plugin.
 *
 * Features:
 * - Adds an indicator icon to menu items that contain a `.submenu`.
 * - Opens/closes sub menus with animation.
 * - Works for horizontal or vertical menus.
 * - Supports inline (`--menu-submenu-position:relative`) and adjacent
 *   (`--menu-submenu-position:absolute`) submenu styles.
 */
(function($) {
	"use strict";
	let instanceId = 0;

	$.menu = function(element, options) {
		var defaults = {
			debug: false,
			hilight: "",
			arrow: "<i class='icon-next openicon'></i>",
			menuAnimationTime: 250,
			onOpen: function() {},
			onClose: function() {}
		};

		const settingTypes = {
			hilight: "string",
			arrow: "string",
			menuAnimationTime: "string"
		};

		var plugin = this;
		var $element = $(element);
		var eventNamespace = ".menu" + (++instanceId);
		plugin.settings = {};
		plugin.mode = {
			orientation: "horizontal",
			submenuPosition: "absolute",
			submenuShow: "hide"
		};

		function debugLog() {
			if (plugin.settings.debug) {
				console.log.apply(console, ["[menu]"].concat(Array.prototype.slice.call(arguments)));
			}
		}

		function parseDuration(value) {
			if (typeof value === "number") {
				return value;
			}
			if (typeof value !== "string") {
				return defaults.menuAnimationTime;
			}
			let raw = value.trim();
			if (raw.endsWith("ms")) {
				return parseFloat(raw);
			}
			if (raw.endsWith("s")) {
				return parseFloat(raw) * 1000;
			}
			let parsed = parseFloat(raw);
			return Number.isFinite(parsed) ? parsed : defaults.menuAnimationTime;
		}

		function cssVar(name, fallback) {
			var value = getComputedStyle($element.get(0)).getPropertyValue(name);
			if (!value) {
				return fallback;
			}
			return value.trim() || fallback;
		}

		function readMode() {
			plugin.mode.orientation = cssVar("--menu-orientation", "horizontal");
			plugin.mode.submenuPosition = cssVar("--menu-submenu-position", "absolute");
			plugin.mode.submenuShow = cssVar("--menu-submenu-show", "hide");
			debugLog("mode", plugin.mode);
		}

		function isInline() {
			return plugin.mode.submenuPosition === "relative";
		}

		function isInlineHorizontal() {
			return isInline() && plugin.mode.orientation === "horizontal";
		}

		function closeNode($li, runCallbacks) {
			if (!$li.length) {
				return;
			}

			$li.removeClass("open");
			var $submenu = $li.children(".submenu").first();
			$submenu.stop(true, true).attr("aria-hidden", "true").slideUp(plugin.settings.menuAnimationTime, function() {
				$submenu.removeClass("show");
				if (runCallbacks) {
					plugin.settings.onClose.call($submenu.get(0), $li.get(0));
				}
			});

			$submenu.find("li.open").each(function() {
				closeNode($(this), false);
			});
		}

		function positionInlineHorizontalSubmenu($li) {
			if (!isInlineHorizontal()) {
				return;
			}

			var $submenu = $li.children(".submenu").first();
			if (!$submenu.length) {
				return;
			}

			var liLeft = $li.position().left;
			$submenu.css({
				left: (liLeft * -1) + "px",
				top: "100%",
				width: $element.innerWidth() + "px"
			});
		}

		function openNode($li) {
			if (!$li.length) {
				return;
			}

			if (!isInline()) {
				$li.siblings(".open").each(function() {
					closeNode($(this), true);
				});
			}

			var $submenu = $li.children(".submenu").first();
			if (!$submenu.length) {
				return;
			}

			positionInlineHorizontalSubmenu($li);
			$li.addClass("open");
			$submenu
				.addClass("show")
				.attr("aria-hidden", "false")
				.stop(true, true)
				.hide()
				.slideDown(plugin.settings.menuAnimationTime, function() {
					$submenu.css("height", "");
					plugin.settings.onOpen.call($submenu.get(0), $li.get(0));
				});
		}

		function decorateMenu() {
			$element.find(".submenu").each(function() {
				var $submenu = $(this);
				var $parentAnchor = $submenu.prev("a");
				if (!$parentAnchor.length) {
					return;
				}

				if (!$parentAnchor.find("> .openicon").length) {
					$parentAnchor.append(plugin.settings.arrow);
				}

				$parentAnchor.addClass("hasmenu").attr("aria-haspopup", "true").attr("aria-expanded", "false");
				$submenu.attr("aria-hidden", "true");
			});
		}

		function applyHighlight() {
			if (plugin.settings.hilight === "") {
				return;
			}
			var $a = $("#menu_" + plugin.settings.hilight);
			if (!$a.length) {
				return;
			}
			$a.closest("li").addClass("hi");
			$a.parents("li").each(function() {
				openNode($(this));
			});
		}

		function syncModeClasses() {
			$element.toggleClass("menu-inline", isInline());
			$element.toggleClass("menu-adjacent", !isInline());
			$element.toggleClass("menu-inline-horizontal", isInlineHorizontal());
		}

		function bindEvents() {
			$element.off("click" + eventNamespace);
			$(window).off("resize" + eventNamespace);

			if (plugin.mode.submenuShow === "hover") {
				return;
			}

			$element.on("click" + eventNamespace, "a.hasmenu > .openicon", function(e) {
				e.preventDefault();
				e.stopPropagation();

				readMode();
				syncModeClasses();

				var $li = $(this).closest("li");
				if ($li.hasClass("open")) {
					closeNode($li, true);
					$li.children("a").attr("aria-expanded", "false");
				} else {
					openNode($li);
					$li.children("a").attr("aria-expanded", "true");
				}
			});

			$(window).on("resize" + eventNamespace, function() {
				readMode();
				syncModeClasses();
				if (!isInlineHorizontal()) {
					$element.find(".submenu").css({ left: "", top: "", width: "" });
					return;
				}
				$element.find("li.open").each(function() {
					positionInlineHorizontalSubmenu($(this));
				});
			});
		}

		plugin.init = function() {
			let cssSettings = (typeof clik !== "undefined" && typeof clik.parseCssVars === "function")
				? clik.parseCssVars($element, settingTypes)
				: {};

			plugin.settings = $.extend({}, defaults, cssSettings, options);
			plugin.settings.menuAnimationTime = parseDuration(plugin.settings.menuAnimationTime);

			readMode();
			decorateMenu();
			syncModeClasses();
			bindEvents();
			applyHighlight();
		};

		plugin.init();
	};

	$.fn.menu = function(options) {
		return this.each(function() {
			if (undefined === $(this).data("menu")) {
				var plugin = new $.menu(this, options);
				$(this).data("menu", plugin);
			}
		});
	};
})(jQuery);
