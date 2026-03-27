(function (window, document) {
  'use strict';

  var DEFAULTS = {
    jsonUrl: '',
    styles: [],
    storageKey: 'clik-selected-stylesheet',
    panelTitle: 'Styles',
    launcherLabel: '🎨',
    launcherTop: 16,
    launcherRight: 16,
    variantClass: '',
    stylesheetLinkId: 'clik-dynamic-stylesheet',
    replaceLinkSelector: '',
    previewZoomWidth: 420,
    closeOnSelect: true
  };

  function ensureCss() {
    if (document.getElementById('clik-style-switcher-css')) return;
    var css = '' +
      '.clik-style-launcher{position:fixed;z-index:9998;width:42px;height:42px;border-radius:50%;border:none;background:#111;color:#fff;cursor:move;box-shadow:0 6px 18px rgba(0,0,0,.2);display:flex;align-items:center;justify-content:center;font-size:20px;}' +
      '.clik-style-launcher:focus{outline:2px solid #4f9df5;}' +
      '.clik-style-modal-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.4);z-index:9999;display:none;}' +
      '.clik-style-modal{position:fixed;top:70px;right:20px;width:520px;max-width:calc(100vw - 40px);max-height:80vh;background:#fff;border-radius:8px;box-shadow:0 18px 45px rgba(0,0,0,.35);overflow:hidden;display:flex;flex-direction:column;}' +
      '.clik-style-modal-header{padding:10px 12px;background:#111;color:#fff;display:flex;justify-content:space-between;align-items:center;cursor:move;}' +
      '.clik-style-modal-body{display:grid;grid-template-columns:1fr 200px;min-height:220px;overflow:hidden;}' +
      '.clik-style-list{margin:0;padding:8px;list-style:none;overflow:auto;}' +
      '.clik-style-list button{width:100%;text-align:left;border:1px solid #ddd;background:#fafafa;padding:8px 10px;margin-bottom:8px;border-radius:6px;cursor:pointer;}' +
      '.clik-style-list button:hover{background:#f2f2f2;}' +
      '.clik-style-list .clik-title{display:block;font-weight:600;}' +
      '.clik-style-list .clik-desc{font-size:12px;color:#666;display:block;margin-top:3px;}' +
      '.clik-style-preview{border-left:1px solid #e5e5e5;padding:10px;background:#fcfcfc;overflow:auto;}' +
      '.clik-style-preview img{width:100%;height:auto;border-radius:4px;display:block;margin-top:8px;}' +
      '.clik-style-preview-zoom{position:fixed;z-index:10000;display:none;background:#fff;padding:8px;border-radius:8px;box-shadow:0 18px 45px rgba(0,0,0,.35);}' +
      '.clik-style-preview-zoom img{display:block;width:100%;height:auto;border-radius:4px;}' +
      '.clik-style-close{border:none;background:transparent;color:#fff;font-size:20px;cursor:pointer;line-height:1;}' +
      '.clik-style-launcher.native{background:#222;}';
    var style = document.createElement('style');
    style.id = 'clik-style-switcher-css';
    style.textContent = css;
    document.head.appendChild(style);
  }

  function createDraggable(handle, target, onStop) {
    var dragging = false;
    var startX = 0, startY = 0, startLeft = 0, startTop = 0;

    handle.addEventListener('mousedown', function (e) {
      dragging = true;
      startX = e.clientX;
      startY = e.clientY;
      var rect = target.getBoundingClientRect();
      startLeft = rect.left;
      startTop = rect.top;
      document.body.style.userSelect = 'none';
      e.preventDefault();
    });

    window.addEventListener('mousemove', function (e) {
      if (!dragging) return;
      var left = Math.max(0, startLeft + (e.clientX - startX));
      var top = Math.max(0, startTop + (e.clientY - startY));
      target.style.left = left + 'px';
      target.style.top = top + 'px';
      target.style.right = 'auto';
    });

    window.addEventListener('mouseup', function () {
      if (!dragging) return;
      dragging = false;
      document.body.style.userSelect = '';
      if (onStop) onStop(target);
    });
  }

  function fetchStyles(config) {
    if (!config.jsonUrl) return Promise.resolve(config.styles || []);
    return fetch(config.jsonUrl)
      .then(function (res) { return res.ok ? res.json() : []; })
      .then(function (data) { return data.styles || data; });
  }

  function applyStylesheet(config, href) {
    if (!href) return;
    var link = null;

    if (config.replaceLinkSelector) {
      link = document.querySelector(config.replaceLinkSelector);
    }

    if (!link) {
      link = document.getElementById(config.stylesheetLinkId);
      if (!link) {
        link = document.createElement('link');
        link.rel = 'stylesheet';
        link.id = config.stylesheetLinkId;
        document.head.appendChild(link);
      }
    }
    link.href = href;
    localStorage.setItem(config.storageKey, href);
  }

  function buildUI(config) {
    ensureCss();

    var launcher = document.createElement('button');
    launcher.type = 'button';
    launcher.className = 'clik-style-launcher ' + config.variantClass;
    launcher.style.top = config.launcherTop + 'px';
    launcher.style.right = config.launcherRight + 'px';
    launcher.innerHTML = config.launcherLabel;
    launcher.title = 'Choose stylesheet';

    var backdrop = document.createElement('div');
    backdrop.className = 'clik-style-modal-backdrop';
    backdrop.innerHTML = '<div class="clik-style-modal" role="dialog" aria-modal="true">' +
      '<div class="clik-style-modal-header"><strong>' + config.panelTitle + '</strong><button class="clik-style-close" aria-label="Close">×</button></div>' +
      '<div class="clik-style-modal-body"><ul class="clik-style-list"></ul><aside class="clik-style-preview"><em>Hover for preview</em></aside></div>' +
      '</div>';

    document.body.appendChild(launcher);
    document.body.appendChild(backdrop);

    var modal = backdrop.querySelector('.clik-style-modal');
    var list = backdrop.querySelector('.clik-style-list');
    var preview = backdrop.querySelector('.clik-style-preview');

    function closeModal() { backdrop.style.display = 'none'; }
    function openModal() { backdrop.style.display = 'block'; }

    launcher.addEventListener('click', function () { openModal(); });
    backdrop.addEventListener('click', function (e) { if (e.target === backdrop) closeModal(); });
    backdrop.querySelector('.clik-style-close').addEventListener('click', closeModal);

    createDraggable(launcher, launcher);
    createDraggable(backdrop.querySelector('.clik-style-modal-header'), modal);

    return {
      list: list,
      preview: preview,
      closeModal: closeModal
    };
  }

  function getZoomPanel() {
    var panel = document.getElementById('clik-style-preview-zoom');
    if (panel) return panel;
    panel = document.createElement('div');
    panel.id = 'clik-style-preview-zoom';
    panel.className = 'clik-style-preview-zoom';
    panel.innerHTML = '<img alt=\"Expanded preview\">';
    document.body.appendChild(panel);
    return panel;
  }

  function hideZoomPreview() {
    var panel = document.getElementById('clik-style-preview-zoom');
    if (!panel) return;
    panel.style.display = 'none';
  }

  function bindZoomPreview(ui, config) {
    ui.preview.addEventListener('mouseover', function (e) {
      if (e.target.tagName !== 'IMG') return;
      var panel = getZoomPanel();
      var img = panel.querySelector('img');
      img.src = e.target.src;
      img.alt = e.target.alt || 'Expanded preview';
      panel.style.width = config.previewZoomWidth + 'px';
      panel.style.left = Math.max(8, e.clientX - config.previewZoomWidth - 16) + 'px';
      panel.style.top = Math.max(8, e.clientY - 24) + 'px';
      panel.style.display = 'block';
    });

    ui.preview.addEventListener('mouseout', function (e) {
      if (e.target.tagName !== 'IMG') return;
      hideZoomPreview();
    });

    ui.preview.addEventListener('click', function (e) {
      if (e.target.tagName !== 'IMG') return;
      hideZoomPreview();
    });
  }

  function renderStyles(ui, config, styles) {
    ui.list.innerHTML = '';
    styles.forEach(function (style) {
      var item = document.createElement('li');
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.innerHTML = '<span class="clik-title">' + style.title + '</span>' +
        '<span class="clik-desc">' + (style.description || '') + '</span>';

      btn.addEventListener('mouseenter', function () {
        ui.preview.innerHTML = '<strong>' + (style.title || '') + '</strong><p>' + (style.description || '') + '</p>' +
          (style.previewImage ? ('<img src="' + style.previewImage + '" alt="' + style.title + ' preview">') : '<em>No preview image</em>');
      });

      btn.addEventListener('click', function () {
        applyStylesheet(config, style.href);
        if (config.closeOnSelect) ui.closeModal();
      });

      item.appendChild(btn);
      ui.list.appendChild(item);
    });
  }

  function start(config) {
    var merged = Object.assign({}, DEFAULTS, config || {});
    var saved = localStorage.getItem(merged.storageKey);
    if (saved) applyStylesheet(merged, saved);

    var ui = buildUI(merged);
    bindZoomPreview(ui, merged);
    return fetchStyles(merged).then(function (styles) {
      renderStyles(ui, merged, styles || []);
      return { config: merged, styles: styles || [] };
    });
  }

  window.StyleSheetSwitcherNative = {
    init: function (config) { return start(config); }
  };
})(window, document);
