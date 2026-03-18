/**
 * Ticketbox i18n — lightweight client-side internationalisation.
 *
 * How it works:
 *   1. Loads a JSON dictionary from /assets/i18n/{lang}.json
 *   2. Scans the DOM for elements with [data-i18n] attributes.
 *   3. Replaces textContent (or placeholder / aria-label) with the
 *      translated string.
 *   4. Persists the user's choice in localStorage.
 *
 * Usage in HTML:
 *   <span data-i18n="nav.events">Sự kiện</span>
 *   <input data-i18n-placeholder="chat.placeholder_active" placeholder="Nhập tin nhắn...">
 *
 * Programmatic API:
 *   i18n.t('chat.cooldown', minutesLeft)  → "Please wait 5 minutes…"
 *   i18n.currentLang                      → "vi"
 *   i18n.setLanguage('en')                → switches lang & re-renders
 */
(function () {
    'use strict';

    var STORAGE_KEY = 'ticketbox.language';
    var DEFAULT_LANG = 'vi';
    var SUPPORTED = ['vi', 'en', 'ja'];

    var cache = {};
    var currentLang = DEFAULT_LANG;
    var contextPath = '';

    /** Detect language from localStorage or browser settings. */
    function detectLanguage() {
        var saved = (localStorage.getItem(STORAGE_KEY) || '').toLowerCase();
        if (SUPPORTED.indexOf(saved) !== -1) return saved;

        var browserLang = (navigator.language || '').substring(0, 2).toLowerCase();
        if (SUPPORTED.indexOf(browserLang) !== -1) return browserLang;

        return DEFAULT_LANG;
    }

    /** Fetch and cache a language dictionary. */
    function loadDictionary(lang, callback) {
        if (cache[lang]) {
            callback(cache[lang]);
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.open('GET', contextPath + '/assets/i18n/' + lang + '.json', true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== 4) return;
            if (xhr.status === 200) {
                try {
                    cache[lang] = JSON.parse(xhr.responseText);
                } catch (e) {
                    cache[lang] = {};
                }
            } else {
                cache[lang] = {};
            }
            callback(cache[lang]);
        };
        xhr.send();
    }

    /**
     * Translate a key, optionally replacing {0}, {1}, … with extra args.
     * Falls back to the key itself if no translation found.
     */
    function t(key) {
        var dict = cache[currentLang] || {};
        var text = dict[key] || key;
        for (var i = 1; i < arguments.length; i++) {
            text = text.replace('{' + (i - 1) + '}', arguments[i]);
        }
        return text;
    }

    /** Apply translations to all [data-i18n*] elements in the DOM. */
    function applyTranslations() {
        var elements = document.querySelectorAll('[data-i18n]');
        for (var i = 0; i < elements.length; i++) {
            var el = elements[i];
            var key = el.getAttribute('data-i18n');
            if (key) el.textContent = t(key);
        }

        var placeholders = document.querySelectorAll('[data-i18n-placeholder]');
        for (var j = 0; j < placeholders.length; j++) {
            var ph = placeholders[j];
            var pKey = ph.getAttribute('data-i18n-placeholder');
            if (pKey) ph.placeholder = t(pKey);
        }

        var ariaLabels = document.querySelectorAll('[data-i18n-aria]');
        for (var k = 0; k < ariaLabels.length; k++) {
            var al = ariaLabels[k];
            var aKey = al.getAttribute('data-i18n-aria');
            if (aKey) al.setAttribute('aria-label', t(aKey));
        }

        var titles = document.querySelectorAll('[data-i18n-title]');
        for (var m = 0; m < titles.length; m++) {
            var ti = titles[m];
            var tKey = ti.getAttribute('data-i18n-title');
            if (tKey) ti.title = t(tKey);
        }

        document.documentElement.setAttribute('lang', currentLang);
    }

    /** Switch language, persist, and re-render. */
    function setLanguage(lang) {
        if (SUPPORTED.indexOf(lang) === -1) lang = DEFAULT_LANG;
        currentLang = lang;
        localStorage.setItem(STORAGE_KEY, lang);

        // Clear old googtrans cookies to avoid stale Google Translate interference
        document.cookie = 'googtrans=; path=/; max-age=0';
        document.cookie = 'googtrans=; path=' + contextPath + '; max-age=0';

        loadDictionary(lang, function () {
            applyTranslations();
        });
    }

    /** Bootstrap — call once on DOMContentLoaded. */
    function init() {
        var body = document.body;
        contextPath = (body && body.dataset.contextPath) || '';

        currentLang = detectLanguage();

        // Sync the language selector if it exists
        var sel = document.getElementById('navLanguageSelect');
        if (sel) {
            sel.value = currentLang;
            sel.addEventListener('change', function () {
                setLanguage(this.value);
            });
        }

        loadDictionary(currentLang, function () {
            applyTranslations();
        });
    }

    // Auto-init
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Public API
    window.i18n = {
        t: t,
        setLanguage: setLanguage,
        applyTranslations: applyTranslations,
        get currentLang() { return currentLang; }
    };
})();
