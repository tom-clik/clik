# Form responses

Use `$(container).clikForm()` with jQuery Validate, Select2, Elastic, and ApiHelper.
The ClikForm JavaScript provides client validation and AJAX submission. Only the
separate `clikForm.css` stylesheet is deprecated and removed: use the existing
forms styles included in the manifest-defined Clik CSS package.

Follow `_testing/forms.html`: each `.fieldrow` contains a `.fieldLabel` and a
`.field` holding inputs with `name` attributes. Link labels to input IDs.
Do not also bind the same form using ApiHelper's `js-api-post-form` class.

Failed responses may return `ERRORS` or `errors` keyed by input name:

```json
{"OK": 0, "MESSAGE": "Please correct the form", "ERRORS": {"email": "Enter a valid email"}}
```

Flat field-name errors also work. ClikForm adds `.error` to the affected row and
inserts its message as a direct child, using the forms stylesheet's error grid
area. Correcting fields clears their messages without removing the inputs.

Successful responses can replace element contents by ID:

```json
{"OK": 1, "html": [{"id": "form-container", "content": "<p>Saved successfully</p>"}]}
```

ApiHelper applies these HTML replacements, and ClikForm preserves them without
showing its fallback success message. Escape user data in server-generated HTML.
Rebuild the CSS package using `node tools/build_css.mjs` after changing sources.
