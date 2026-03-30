/*

# ApiHelper Complete Usage Guide

## What this script does

`ApiHelper` is a shared browser-side helper for making API calls consistently across your site.

It handles:

* GET API links
* POST form submits
* login/session expiry handling
* inline and popup messages
* JSON and `FormData` requests
* sending serialized form JSON in a field like `data`
* reusable success, error, before, and complete handlers
* per-element custom arguments
* busy/loading states

It is designed to work well in normal browser pages and alongside jQuery plugins.

---

# 1. Add the script to your page

Load your shared script after the page content or in a bundled JS file.

```html
<script src="/js/api-helper.js"></script>
<script>
    ApiHelper.setConfig({
        defaultInlineMessageId: "formMessages",
        loginHandler: function (data, response) {
            if (window.jQuery && $("#loginModal").length) {
                $("#loginModal").modal("show");
                return;
            }

            alert("Please log in.");
        }
    });

    ApiHelper.bind();
</script>
```

---

# 2. Basic concepts

The script gives you one global object:

```javascript
ApiHelper
```

Main things it can do:

* `ApiHelper.request()` → make manual API calls
* `ApiHelper.submitForm()` → submit a form programmatically
* `ApiHelper.serializeFormToJson()` → convert a form into JSON
* `ApiHelper.registerHandler()` → define reusable page actions
* `ApiHelper.bind()` → automatically wire HTML links/forms to the helper

---

# 3. How automatic binding works

Once you call:

```javascript
ApiHelper.bind();
```

the script watches the page for:

* links with class `.js-api-get`
* forms with class `.js-api-post-form`

So instead of manually adding click and submit JS everywhere, you can configure behavior in HTML.

---

# 4. Using GET links

## Basic GET link

```html
<div id="formMessages"></div>

<a href="/api/user/details?id=123"
   class="js-api-get"
   data-inline-message-id="formMessages">
    Load User Details
</a>
```

When clicked:

* normal page navigation is stopped
* `href` is used as the API URL
* a GET request is sent
* any returned messages are shown
* login expiry is handled automatically

---

## GET link with confirmation

```html
<a href="/api/user/delete?id=123"
   class="js-api-get"
   data-confirm="Are you sure you want to delete this user?"
   data-inline-message-id="formMessages">
    Delete User
</a>
```

If `data-confirm` exists, the request only runs if the user confirms.

---

## GET link with busy text

```html
<a href="/api/user/delete?id=123"
   class="js-api-get"
   data-confirm="Delete this user?"
   data-inline-message-id="formMessages"
   data-busy-text="Deleting...">
    Delete User
</a>
```

While the request runs, the link text changes to `Deleting...`.

If you only want the busy class (and do not want the link/button text replaced),
set `data-busy-class-only="true"`.

```html
<a href="/api/user/delete?id=123"
   class="js-api-get"
   data-busy-class-only="true">
    <i class="icon-dollar"></i>
</a>
```

---

# 5. Using POST forms

## Basic form submit

```html
<form class="js-api-post-form"
      action="/api/user/save"
      method="POST"
      data-inline-message-id="formMessages">

    <input type="text" name="name" value="John Smith">
    <input type="email" name="email" value="john@example.com">

    <button type="submit">Save</button>
</form>
```

When submitted:

* normal browser form submission is stopped
* the form is sent through `ApiHelper`
* messages are displayed
* login status is checked
* handlers can run on success/error

---

# 6. Form submit modes

The form helper supports several submit modes using `data-submit-mode`.

## Mode: `form`

Send the form as standard `FormData`.

```html
<form class="js-api-post-form"
      action="/api/user/save"
      method="POST"
      data-submit-mode="form">
```

Use this when:

* your backend expects normal posted fields
* you may include files
* you want standard form behavior

---

## Mode: `json`

Serialize the form and send it as JSON request body.

```html
<form class="js-api-post-form"
      action="/api/user/save"
      method="POST"
      data-submit-mode="json">
```

Use this when:

* your API expects JSON
* you are not uploading files
* your backend is JSON-first

Example payload:

```json
{
  "name": "John Smith",
  "email": "john@example.com"
}
```

---

## Mode: `jsonField`

Serialize the form to JSON, then send it inside a single `FormData` field.

```html
<form class="js-api-post-form"
      action="/api/user/save"
      method="POST"
      data-submit-mode="jsonField"
      data-json-field-name="data">
```

Example posted field:

```text
data = {"name":"John Smith","email":"john@example.com"}
```

Use this when:

* your backend expects a single field like `data`
* you want normal form posting with a JSON payload inside it

---

## Mode: `formPlusJsonField`

Send both:

* regular form fields
* a serialized JSON copy in a field like `data`

```html
<form class="js-api-post-form"
      action="/api/user/save"
      method="POST"
      data-submit-mode="formPlusJsonField"
      data-json-field-name="data">
```

Use this when:

* you want backward compatibility
* some server code still reads normal fields
* newer code reads the `data` JSON field

---

# 7. Inline and popup messages

The script expects the API may return messages like this:

```json
{
  "message": [
    {
      "type": "success",
      "text": "User saved successfully.",
      "display": "inline"
    },
    {
      "type": "info",
      "text": "Changes will appear shortly.",
      "display": "popup"
    }
  ]
}
```

## Message fields

Each message can have:

* `type`: `success`, `error`, `warning`, `info`
* `text` or `message`: the message text
* `display`: `inline` or `popup`

## Inline messages

For inline messages, you need a container:

```html
<div id="formMessages"></div>
```

Then point your link or form at it:

```html
data-inline-message-id="formMessages"
```

## Popup messages

Popup messages use `alert()` by default, unless you configure a custom popup handler.

---

# 8. Login/session expiry handling

The script checks whether the response means the user is not logged in.

By default it looks for:

* HTTP status `401`
* `data.status === "not_logged_in"`
* `data.loggedIn === false`

If detected, it calls your configured `loginHandler`.

Example:

```javascript
ApiHelper.setConfig({
    loginHandler: function (data, response) {
        $("#loginModal").modal("show");
    }
});
```

If you do not provide one, it falls back to a simple alert.

---

# 9. Using handlers

Handlers let you define reusable actions for:

* before a request
* after a successful request
* after a failed request
* when the request completes either way

You register handlers in JavaScript, then reference them by name in HTML.

---

## Registering a handler

```javascript
ApiHelper.registerHandler("loadUserSuccess", function (context) {
    console.log(context.data);
});
```

---

## Attaching a handler in HTML

```html
<a href="/api/user/details?id=123"
   class="js-api-get"
   data-on-success="loadUserSuccess">
    Load User
</a>
```

---

# 10. Available handler attributes

You can use these on both links and forms:

```html
data-on-before="handlerName"
data-on-success="handlerName"
data-on-error="handlerName"
data-on-complete="handlerName"
data-handler-args='{"targetId":"output"}'
```

## What they mean

* `data-on-before` → runs before the request
* `data-on-success` → runs if the request succeeds
* `data-on-error` → runs if the request fails
* `data-on-complete` → always runs after the request
* `data-handler-args` → custom JSON passed to the handler

---

# 11. What a handler receives

Each handler gets one `context` object.

Example:

```javascript
ApiHelper.registerHandler("exampleHandler", function (context) {
    console.log(context);
});
```

The `context` contains:

* `context.helper` → the `ApiHelper` instance
* `context.eventType` → such as `get:success` or `form:error`
* `context.element` → the link or form
* `context.triggerElement` → usually the clicked link or submit button
* `context.data` → parsed response body
* `context.result` → full helper result object
* `context.response` → raw fetch response
* `context.error` → thrown error for network failures
* `context.args` → custom args from `data-handler-args`
* `context.requestOptions` → request settings
* `context.originalEvent` → original DOM event
* `context.url` → request URL
* `context.method` → request method

---

# 12. Example handlers

## Success handler that writes output to a target element

```javascript
ApiHelper.registerHandler("writeToOutput", function (context) {
    if (!context.args.targetId) {
        return;
    }

    document.getElementById(context.args.targetId).textContent =
        JSON.stringify(context.data, null, 2);
});
```

HTML:

```html
<a href="/api/user/details?id=123"
   class="js-api-get"
   data-on-success="writeToOutput"
   data-handler-args='{"targetId":"output"}'>
    Load User
</a>
```

---

## Error handler

```javascript
ApiHelper.registerHandler("showRequestError", function (context) {
    let message = "Request failed.";

    if (context.error) {
        message = context.error.message || message;
    }
    else if (context.data && context.data.error) {
        message = context.data.error;
    }
    else if (context.response) {
        message = "Request failed with status " + context.response.status;
    }

    if (context.args.targetId) {
        document.getElementById(context.args.targetId).textContent = message;
    }
});
```

---

## Before handler that validates a form

```javascript
ApiHelper.registerHandler("validateUserForm", function (context) {
    const nameField = context.element.querySelector('[name="name"]');

    if (!nameField || !nameField.value.trim()) {
        alert("Name is required.");
        return false;
    }
});
```

If a `before` handler returns `false`, the request is cancelled.

---

## Complete handler

```javascript
ApiHelper.registerHandler("logComplete", function (context) {
    console.log("Request finished:", context.eventType, context);
});
```

---

# 13. Using custom handler arguments

You can pass per-element settings into handlers using JSON.

Example:

```html
data-handler-args='{"targetId":"output","resetForm":true}'
```

Then in a handler:

```javascript
ApiHelper.registerHandler("afterSaveUser", function (context) {
    if (context.args.resetForm) {
        context.element.reset();
    }

    if (context.args.targetId) {
        document.getElementById(context.args.targetId).textContent =
            "Saved successfully.";
    }
});
```

This is useful because the same handler can be reused for different forms or links.

---

# 14. Manual API calls

You do not have to use only HTML-bound links/forms. You can also call the helper directly.

## Simple GET request

```javascript
const result = await ApiHelper.request("/api/user/details?id=123", {
    method: "GET",
    inlineMessageId: "formMessages"
});

if (result.ok) {
    console.log(result.data);
}
```

## POST JSON request

```javascript
const result = await ApiHelper.request("/api/user/save", {
    method: "POST",
    body: {
        name: "John Smith",
        email: "john@example.com"
    },
    inlineMessageId: "formMessages"
});
```

## POST `FormData`

```javascript
const formData = new FormData();
formData.append("name", "John Smith");
formData.append("email", "john@example.com");

const result = await ApiHelper.request("/api/user/save", {
    method: "POST",
    body: formData,
    inlineMessageId: "formMessages"
});
```

---

# 15. Serializing forms to JSON

You can manually serialize a form:

```javascript
const form = document.getElementById("myForm");
const data = ApiHelper.serializeFormToJson(form);

console.log(data);
```

Given a form like:

```html
<form id="myForm">
    <input type="text" name="name" value="John Smith">
    <input type="email" name="email" value="john@example.com">
    <input type="checkbox" name="isActive" value="1">
</form>
```

you get:

```json
{
  "name": "John Smith",
  "email": "john@example.com",
  "isActive": 0
}
```

If the checkbox is checked:

```json
{
  "name": "John Smith",
  "email": "john@example.com",
  "isActive": "1"
}
```

---

# 16. Checkbox behavior

## Single checkbox

A single checkbox is always included in serialized JSON:

* checked → its value, usually `"1"`
* unchecked → `0`

Example:

```html
<input type="checkbox" name="subscribe" value="1">
```

Results in either:

```json
{ "subscribe": "1" }
```

or:

```json
{ "subscribe": 0 }
```

## Multiple checkboxes with same name

These are treated as an array.

```html
<label><input type="checkbox" name="roles" value="admin"> Admin</label>
<label><input type="checkbox" name="roles" value="editor"> Editor</label>
<label><input type="checkbox" name="roles" value="viewer"> Viewer</label>
```

Results in:

```json
{ "roles": ["admin", "editor"] }
```

If none are checked:

```json
{ "roles": [] }
```

---

# 17. Sending serialized JSON in a field called `data`

This is one of the most useful patterns.

## Example form

```html
<form class="js-api-post-form"
      action="/api/user/save"
      method="POST"
      data-submit-mode="jsonField"
      data-json-field-name="data"
      data-inline-message-id="formMessages">
    <input type="text" name="name" value="John Smith">
    <input type="email" name="email" value="john@example.com">
    <button type="submit">Save</button>
</form>
```

This posts a form field like:

```text
data={"name":"John Smith","email":"john@example.com"}
```

This is useful if your backend expects something like:

* PHP: `$_POST["data"]`
* ColdFusion: `form.data`
* Node form parsers: `req.body.data`

---

# 18. Building form data manually with JSON field

You can also do this yourself in JS.

```javascript
const form = document.getElementById("myForm");
const formData = ApiHelper.buildFormDataWithJson(form, "data");

await ApiHelper.request("/api/user/save", {
    method: "POST",
    body: formData
});
```

This creates a `FormData` object with only one field: `data`.

---

# 19. Submitting forms programmatically

You can submit a form directly in code.

```javascript
const form = document.getElementById("myForm");

const result = await ApiHelper.submitForm(form, {
    inlineMessageId: "formMessages",
    submitMode: "jsonField",
    jsonFieldName: "data"
});
```

You can also use jQuery forms:

```javascript
const result = await ApiHelper.submitJQueryForm($("#myForm"), {
    inlineMessageId: "formMessages",
    submitMode: "jsonField",
    jsonFieldName: "data"
});
```

---

# 20. Custom popup message UI

By default popup messages use `alert()`. You can replace that with your own UI.

Example with jQuery:

```javascript
ApiHelper.setConfig({
    popupMessageHandler: function (text, type, message) {
        $("<div>")
            .addClass("popup-message popup-" + type)
            .text(text)
            .appendTo("body")
            .delay(2500)
            .fadeOut(400, function () {
                $(this).remove();
            });
    }
});
```

---

# 21. Custom inline message rendering

You can also control how inline messages are rendered.

```javascript
ApiHelper.setConfig({
    inlineMessageRenderer: function (container, text, type, message) {
        const div = document.createElement("div");
        div.className = "my-alert my-alert-" + type;
        div.innerHTML = "<strong>" + type.toUpperCase() + ":</strong> " + text;
        container.appendChild(div);
    }
});
```

---

# 22. Full example page

Here’s a complete example you can copy to test.

```html
<div id="formMessages"></div>
<pre id="output"></pre>

<a href="/api/user/details?id=123"
   class="js-api-get"
   data-inline-message-id="formMessages"
   data-on-success="loadUserSuccess"
   data-on-error="showRequestError"
   data-on-complete="logComplete"
   data-handler-args='{"targetId":"output"}'>
    Load User Details
</a>

<hr>

<form class="js-api-post-form"
      action="/api/user/save"
      method="POST"
      data-inline-message-id="formMessages"
      data-submit-mode="jsonField"
      data-json-field-name="data"
      data-on-before="validateUserForm"
      data-on-success="afterSaveUser"
      data-on-error="showRequestError"
      data-on-complete="logComplete"
      data-handler-args='{"targetId":"output","resetForm":true}'>

    <div>
        <label>Name</label><br>
        <input type="text" name="name" value="John Smith">
    </div>

    <div>
        <label>Email</label><br>
        <input type="email" name="email" value="john@example.com">
    </div>

    <div>
        <label>Subscribe</label>
        <input type="checkbox" name="subscribe" value="1">
    </div>

    <button type="submit" data-busy-text="Saving...">Save</button>
</form>

<script>
    ApiHelper.setConfig({
        defaultInlineMessageId: "formMessages",
        loginHandler: function () {
            alert("Show login popup here");
        }
    });

    ApiHelper.registerHandler("loadUserSuccess", function (context) {
        document.getElementById(context.args.targetId).textContent =
            "GET success:\n" + JSON.stringify(context.data, null, 2);
    });

    ApiHelper.registerHandler("validateUserForm", function (context) {
        const nameField = context.element.querySelector('[name="name"]');
        if (!nameField.value.trim()) {
            alert("Name is required.");
            return false;
        }
    });

    ApiHelper.registerHandler("afterSaveUser", function (context) {
        if (context.args.resetForm) {
            context.element.reset();
        }

        document.getElementById(context.args.targetId).textContent =
            "POST success:\n" + JSON.stringify(context.data, null, 2);
    });

    ApiHelper.registerHandler("showRequestError", function (context) {
        let message = "Request failed.";

        if (context.error) {
            message = context.error.message || message;
        }
        else if (context.data && context.data.error) {
            message = context.data.error;
        }
        else if (context.response) {
            message = "Request failed with status " + context.response.status;
        }

        if (context.args.targetId) {
            document.getElementById(context.args.targetId).textContent = message;
        }
    });

    ApiHelper.registerHandler("logComplete", function (context) {
        console.log("Complete:", context);
    });

    ApiHelper.bind();
</script>
```

---

# 23. Recommended response format from your API

The script works best if your API returns JSON like this:

```json
{
  "success": true,
  "data": {
    "userId": 123,
    "name": "John Smith"
  },
  "messages": [
    {
      "type": "success",
      "text": "User saved successfully.",
      "display": "inline"
    }
  ]
}
```

For login expiry:

```json
{
  "loggedIn": false,
  "messages": [
    {
      "type": "warning",
      "text": "Your session has expired.",
      "display": "popup"
    }
  ]
}
```

For errors:

```json
{
  "error": "Validation failed.",
  "messages": [
    {
      "type": "error",
      "text": "Please correct the highlighted fields.",
      "display": "inline"
    }
  ]
}
```

---

# 24. CSS for inline messages and busy state

```css
.api-message {
    padding: 10px 12px;
    margin-bottom: 10px;
    border-radius: 4px;
    border: 1px solid transparent;
    font-size: 14px;
}

.api-message-success {
    background: #eaf7ea;
    border-color: #b7ddb7;
    color: #216e21;
}

.api-message-error {
    background: #fdeaea;
    border-color: #efb7b7;
    color: #9f1d1d;
}

.api-message-warning {
    background: #fff8e5;
    border-color: #ecd9a3;
    color: #8a6d1d;
}

.api-message-info {
    background: #eaf4fd;
    border-color: #b7d4ef;
    color: #1d4f91;
}

.is-busy {
    opacity: 0.7;
    pointer-events: none;
}
```

---

# 25. Best practices

A few recommendations for using the helper cleanly:

Use handlers for page behavior, not inline JS.
Good:

```html
data-on-success="afterSaveUser"
```

Not ideal:

```html
onclick="doSomethingComplicated()"
```

Keep API responses consistent.
Returning `messages` in the same format from all endpoints makes the helper much more useful.

Use `jsonField` when your backend expects one field like `data`.
Use `json` when your backend is designed for JSON APIs.
Use `form` when posting files or standard form fields.

Put reusable display logic into handlers.
For example, one handler for:

* writing output
* removing rows
* resetting forms
* redirecting after save

Use `data-handler-args` to customize each element without writing a new handler every time.

---

# 26. Troubleshooting

## My handler does not run

Check:

* the handler name matches exactly
* you called `ApiHelper.registerHandler("name", fn)`
* the HTML `data-on-success` or `data-on-error` matches that name
* `ApiHelper.bind()` was called

## Inline messages do not show

Check:

* `data-inline-message-id` matches an actual element ID
* the response message has `display: "inline"`
* the container exists on the page

## Login popup does not appear

Check:

* your API returns `401`, `loggedIn: false`, or `status: "not_logged_in"`
* `loginHandler` is configured
* the request is actually reaching the helper

## Form posts the page normally

Check:

* the form has class `js-api-post-form`
* `ApiHelper.bind()` was called after the script loaded

## The `data` field contains `[object Object]`

That means JSON was appended without `JSON.stringify()`. Use the helper’s built-in methods or stringify the object before appending.

---

# 27. Quick reference

## Classes

```html
js-api-get
js-api-post-form
```

## Common HTML attributes

```html
data-inline-message-id="formMessages"
data-confirm="Are you sure?"
data-busy-text="Saving..."

data-submit-mode="form"
data-submit-mode="json"
data-submit-mode="jsonField"
data-submit-mode="formPlusJsonField"

data-json-field-name="data"

data-on-before="handlerName"
data-on-success="handlerName"
data-on-error="handlerName"
data-on-complete="handlerName"

data-handler-args='{"targetId":"output"}'
```

## Common JS methods

```javascript
ApiHelper.setConfig(...)
ApiHelper.bind()
ApiHelper.request(...)
ApiHelper.submitForm(...)
ApiHelper.submitJQueryForm(...)
ApiHelper.serializeFormToJson(...)
ApiHelper.buildFormDataWithJson(...)
ApiHelper.registerHandler(...)
ApiHelper.unregisterHandler(...)
ApiHelper.clearInlineMessages(...)
```

---

# 28. Suggested starting pattern

A solid default setup would be:

* one shared `#formMessages` container near the top of the page
* forms using `data-submit-mode="jsonField"` and `data-json-field-name="data"`
* standard `before`, `success`, and `error` handlers reused across pages
* one configured `loginHandler` that opens your site’s login modal

That gives you a consistent API interaction pattern across the whole app.

 */



(function (window, document) {
    "use strict";

    class ApiHelperClass {
        constructor() {
            this.config = {
                loginHandler: null,
                defaultHeaders: {
                    "Content-Type": "application/json"
                },
                getLinkClass: "js-api-get",
                postFormClass: "js-api-post-form",
                busyClass: "is-busy",
                usePopupAlerts: true,

                // Optional hooks for custom UI integrations
                popupMessageHandler: null,   // function (text, type, message) {}
                inlineMessageRenderer: null  // function (container, text, type, message) {}
            };

            this.handlers = {};
            this.bound = false;
        }

        setConfig(options = {}) {
            this.config = Object.assign({}, this.config, options);
        }

        registerHandler(name, fn) {
            if (!name || typeof fn !== "function") {
                throw new Error("registerHandler requires a handler name and function");
            }

            this.handlers[name] = fn;
        }

        unregisterHandler(name) {
            delete this.handlers[name];
        }

        getHandler(name) {
            if (!name) {
                return null;
            }

            if (this.handlers[name]) {
                return this.handlers[name];
            }

            if (typeof window[name] === "function") {
                return window[name];
            }

            return null;
        }

        runHandler(name, context) {
            const handler = this.getHandler(name);

            if (!handler) {
                if (name) {
                    console.warn('Handler not found: "' + name + '"');
                }
                return;
            }

            return handler(context);
        }

        parseHandlerArgs(value) {
            if (!value) {
                return {};
            }

            try {
                return JSON.parse(value);
            }
            catch (error) {
                console.warn("Invalid data-handler-args JSON:", value);
                return {};
            }
        }

        isTrueDataValue(value) {
            if (value == null) {
                return false;
            }

            return ["1", "true", "yes", "on"].includes(String(value).toLowerCase());
        }

        buildHandlerContext(options = {}) {
            return {
                helper: this,
                eventType: options.eventType || null,
                element: options.element || null,
                triggerElement: options.triggerElement || options.element || null,
                data: options.data !== undefined ? options.data : null,
                result: options.result || null,
                response: options.response || null,
                error: options.error || null,
                args: options.args || {},
                requestOptions: options.requestOptions || {},
                originalEvent: options.originalEvent || null,
                url: options.url || null,
                method: options.method || null
            };
        }

        async request(url, options = {}) {
            const isFormData = options.body instanceof FormData;
            const method = (options.method || "GET").toUpperCase();

            const settings = {
                method: method,
                headers: Object.assign({}, this.config.defaultHeaders, options.headers || {})
            };

            if (isFormData) {
                delete settings.headers["Content-Type"];
            }

            if (options.body !== undefined && options.body !== null && method !== "GET") {
                settings.body = isFormData
                    ? options.body
                    : (typeof options.body === "string"
                        ? options.body
                        : JSON.stringify(options.body));
            }

            let response;
            let data;

            try {
                response = await fetch(url, settings);

                const contentType = response.headers.get("content-type") || "";

                if (contentType.includes("application/json")) {
                    data = await response.json();
                }
                else {
                    data = await response.text();
                }
            }
            catch (error) {
                this.showMessage({
                    type: "error",
                    text: "A network error occurred. Please try again.",
                    display: "popup"
                });

                throw error;
            }

            if (data && Array.isArray(data.message)) {
                this.showMessages(
                    data.message
                );
            }

            if (this.isNotLoggedIn(data, response)) {
                if (typeof this.config.loginHandler === "function") {
                    this.config.loginHandler(data, response);
                }
                else {
                    this.defaultLoginPopup();
                }

                return {
                    ok: false,
                    loggedIn: false,
                    data: data,
                    response: response
                };
            }

            this.handleGenericResponse(data);

            let ok = response.ok || false;
            if ( ! ok ) {
                let error = "An error occurred.";

                if ( "statuscode" in data ) {
                    if ( data.statuscode == "500" ) {
                        if ( "id" in data ) {
                            error = data.message ? data.message : error;
                            error += `<br><br>The reference is ${data.id}. Please quote this when contacting <a href="support.cfm">support</a>.`;
                        }
                    }
                    else if ( data.statuscode == "400" && data.errors ) {

                        const errors = Array.isArray(data.errors) ? data.errors : [data.errors];

                        errors.forEach(error => {
                            this.showMessage({
                                type: "error",
                                text: error,
                                display: "bar"
                            });
                        });

                    }
                }
                this.showMessage({
                    type: "error",
                    text: error,
                    display: "bar"
                });
            }

            return {
                ok: response ? response.ok : true,
                loggedIn: true,
                data: data,
                response: response
            };
        }

        handleGenericResponse(data) {

            if (!data || typeof data !== "object") {
                return;
            }

            this.applyHtmlReplacements(data.html);
            this.handleRedirect(data.redirect);
        }

        applyHtmlReplacements(htmlReplacements) {
            if (!Array.isArray(htmlReplacements)) {
                return;
            }

            htmlReplacements.forEach((item) => {
                if (!item || !item.id) {
                    return;
                }

                console.log(item);

                const element = document.getElementById(item.id);
                if (!element) {
                    return;
                }

                element.innerHTML = item.content || "";
            });
        }

        handleRedirect(redirectUrl) {
            if (!redirectUrl || typeof redirectUrl !== "string") {
                return;
            }

            window.location.assign(redirectUrl);
        }

        isNotLoggedIn(data, response) {
            if (response && response.status === 401) {
                return true;
            }

            if (data && data.status === "not_logged_in") {
                return true;
            }

            if (data && data.loggedIn === false) {
                return true;
            }

            return false;
        }

        showMessages(messages) {
            messages.forEach((message) => {
                this.showMessage(message);
            });
        }

        normalizeMessagePlacement(display) {
            switch (display) {
                case "popup":
                    return "dialog";
                default:
                    return display || "popup";
            }
        }

        showMessage(message = {}) {
            const text = message.text ?? message.message ?? "";
            if (!text) return;

            const type = message.type ?? "info";

            clik.showAdminMessage({
                type: type,
                message: text,
                showClose: true,
                placement: this.normalizeMessagePlacement(message.display),
                hideOnClick: type !== "error"
            });
        }

        
        defaultLoginPopup() {
            alert("Your session has expired. Please log in again.");
        }

        serializeFormToJson(form) {
            const obj = {};
            const formData = new FormData(form);

            formData.forEach((value, key) => {
                if (Object.prototype.hasOwnProperty.call(obj, key)) {
                    if (!Array.isArray(obj[key])) {
                        obj[key] = [obj[key]];
                    }
                    obj[key].push(value);
                }
                else {
                    obj[key] = value;
                }
            });

            const checkboxes = form.querySelectorAll('input[type="checkbox"]');
            const checkboxGroups = {};

            checkboxes.forEach((cb) => {
                const name = cb.name;
                if (!name) {
                    return;
                }

                if (!checkboxGroups[name]) {
                    checkboxGroups[name] = [];
                }

                checkboxGroups[name].push(cb);
            });

            Object.keys(checkboxGroups).forEach((name) => {
                const group = checkboxGroups[name];

                if (group.length > 1) {
                    obj[name] = group
                        .filter((cb) => cb.checked)
                        .map((cb) => cb.value);

                    if (!obj[name]) {
                        obj[name] = [];
                    }
                }
                else {
                    const cb = group[0];
                    obj[name] = cb.checked
                        ? (cb.value !== "on" ? cb.value : 1)
                        : 0;
                }
            });

            return obj;
        }

        buildFormDataWithJson(form, fieldName = "data") {
            const json = this.serializeFormToJson(form);
            const formData = new FormData();
            formData.append(fieldName, JSON.stringify(json));
            return formData;
        }

        buildFormDataFromFormAndJson(form, fieldName = "data") {
            const formData = new FormData(form);
            const json = this.serializeFormToJson(form);
            formData.append(fieldName, JSON.stringify(json));
            return formData;
        }

        async submitForm(form, options = {}) {
            if (!form) {
                throw new Error("Form element is required");
            }

            const submitMode = options.submitMode || form.dataset.submitMode || "form";
            const jsonFieldName = options.jsonFieldName || form.dataset.jsonFieldName || "data";

            let body;

            switch (submitMode) {
                case "json":
                    body = this.serializeFormToJson(form);
                    break;

                case "jsonField":
                    body = this.buildFormDataWithJson(form, jsonFieldName);
                    break;

                case "formPlusJsonField":
                    body = this.buildFormDataFromFormAndJson(form, jsonFieldName);
                    break;

                case "form":
                default:
                    body = new FormData(form);
                    break;
            }

            return this.request(options.url || form.action, {
                method: options.method || form.method || "POST",
                body: body,
                headers: options.headers || {}
            });
        }

        async submitJQueryForm($form, options = {}) {
            if (!$form || !$form.length) {
                throw new Error("jQuery form is required");
            }

            return this.submitForm($form[0], options);
        }

        setBusy(element, busyText) {
            if (!element) {
                return;
            }

            element.dataset.apiBusy = "1";
            element.classList.add(this.config.busyClass);

            if (element.tagName === "A") {
                if (!element.dataset.originalText) {
                    element.dataset.originalText = element.textContent;
                }

                if (busyText) {
                    element.textContent = busyText;
                }
            }

            if (
                element.tagName === "BUTTON" ||
                element.tagName === "INPUT" ||
                element.tagName === "SELECT" ||
                element.tagName === "TEXTAREA"
            ) {
                element.disabled = true;
            }
        }

        clearBusy(element) {
            if (!element) {
                return;
            }

            element.dataset.apiBusy = "0";
            element.classList.remove(this.config.busyClass);

            if (element.tagName === "A" && element.dataset.originalText) {
                element.textContent = element.dataset.originalText;
            }

            if (
                element.tagName === "BUTTON" ||
                element.tagName === "INPUT" ||
                element.tagName === "SELECT" ||
                element.tagName === "TEXTAREA"
            ) {
                element.disabled = false;
            }
        }

        isBusy(element) {
            return !!(element && element.dataset.apiBusy === "1");
        }

        bind() {
            if (this.bound) {
                return;
            }

            document.addEventListener("click", (e) => {
                const link = e.target.closest("." + this.config.getLinkClass);
                if (!link) {
                    return;
                }

                e.preventDefault();
                this.handleApiGetLink(link, e);
            });

            document.addEventListener("submit", (e) => {
                
                const form = e.target.closest("." + this.config.postFormClass);
                if (!form) {
                    return;
                }

                e.preventDefault();
                this.handleApiPostForm(form, e);
            });

            this.bound = true;
        }

        async handleApiGetLink(link, originalEvent = null) {
            if (this.isBusy(link)) {
                return;
            }

            const confirmMessage = link.dataset.confirm;
            if (confirmMessage && !window.confirm(confirmMessage)) {
                return;
            }

            const onBefore = link.dataset.onBefore || null;
            const onSuccess = link.dataset.onSuccess || null;
            const onError = link.dataset.onError || null;
            const onComplete = link.dataset.onComplete || null;
            const args = this.parseHandlerArgs(link.dataset.handlerArgs);
            const busyClassOnly = this.isTrueDataValue(link.dataset.busyClassOnly);
            const busyText = busyClassOnly ? null : (link.dataset.busyText ?? "Working...");
            const url = link.href;
            const method = "GET";

            const requestOptions = {
                method: method
            };

            const beforeContext = this.buildHandlerContext({
                eventType: "get:before",
                element: link,
                triggerElement: link,
                args: args,
                requestOptions: requestOptions,
                originalEvent: originalEvent,
                url: url,
                method: method
            });

            const beforeResult = this.runHandler(onBefore, beforeContext);
            if (beforeResult === false) {
                return;
            }

            this.setBusy(link, busyText);

            let result = null;
            let error = null;

            try {
                result = await this.request(url, requestOptions);

                if (!result.loggedIn) {
                    return;
                }

                if (result.ok) {
                    this.runHandler(onSuccess, this.buildHandlerContext({
                        eventType: "get:success",
                        element: link,
                        triggerElement: link,
                        data: result.data,
                        result: result,
                        response: result.response,
                        args: args,
                        requestOptions: requestOptions,
                        originalEvent: originalEvent,
                        url: url,
                        method: method
                    }));
                }
                else {
                    this.runHandler(onError, this.buildHandlerContext({
                        eventType: "get:error",
                        element: link,
                        triggerElement: link,
                        data: result.data,
                        result: result,
                        response: result.response,
                        args: args,
                        requestOptions: requestOptions,
                        originalEvent: originalEvent,
                        url: url,
                        method: method
                    }));
                }
            }
            catch (ex) {
                error = ex;

                this.runHandler(onError, this.buildHandlerContext({
                    eventType: "get:error",
                    element: link,
                    triggerElement: link,
                    error: ex,
                    args: args,
                    requestOptions: requestOptions,
                    originalEvent: originalEvent,
                    url: url,
                    method: method
                }));

                console.error("API GET link failed:", ex);
            }
            finally {
                this.clearBusy(link);

                this.runHandler(onComplete, this.buildHandlerContext({
                    eventType: "get:complete",
                    element: link,
                    triggerElement: link,
                    data: result ? result.data : null,
                    result: result,
                    response: result ? result.response : null,
                    error: error,
                    args: args,
                    requestOptions: requestOptions,
                    originalEvent: originalEvent,
                    url: url,
                    method: method
                }));
            }
        }

        async handleApiPostForm(form, originalEvent = null) {
            if (this.isBusy(form)) {
                return;
            }

            const confirmMessage = form.dataset.confirm;
            if (confirmMessage && !window.confirm(confirmMessage)) {
                return;
            }

            const onBefore = form.dataset.onBefore || null;
            const onSuccess = form.dataset.onSuccess || null;
            const onError = form.dataset.onError || null;
            const onComplete = form.dataset.onComplete || null;
            const args = this.parseHandlerArgs(form.dataset.handlerArgs);
            const submitButton = form.querySelector('[type="submit"]');
            const method = (form.getAttribute("method") || "POST").toUpperCase();
            const url = form.action;

            const requestOptions = {
                submitMode: form.dataset.submitMode || "form",
                jsonFieldName: form.dataset.jsonFieldName || "data",
                method: method
            };

            const beforeContext = this.buildHandlerContext({
                eventType: "form:before",
                element: form,
                triggerElement: submitButton || form,
                args: args,
                requestOptions: requestOptions,
                originalEvent: originalEvent,
                url: url,
                method: method
            });

            const beforeResult = this.runHandler(onBefore, beforeContext);
            if (beforeResult === false) {
                return;
            }

            this.setBusy(form);
            if (submitButton) {
                const busyClassOnly = this.isTrueDataValue(submitButton.dataset.busyClassOnly);
                const busyText = busyClassOnly ? null : (submitButton.dataset.busyText ?? "Working...");
                this.setBusy(submitButton, busyText);
            }

            let result = null;
            let error = null;

            try {
                result = await this.submitForm(form, requestOptions);

                if (!result.loggedIn) {
                    return;
                }

                if (result.ok) {
                    this.runHandler(onSuccess, this.buildHandlerContext({
                        eventType: "form:success",
                        element: form,
                        triggerElement: submitButton || form,
                        data: result.data,
                        result: result,
                        response: result.response,
                        args: args,
                        requestOptions: requestOptions,
                        originalEvent: originalEvent,
                        url: url,
                        method: method
                    }));
                }
                else {
                    this.runHandler(onError, this.buildHandlerContext({
                        eventType: "form:error",
                        element: form,
                        triggerElement: submitButton || form,
                        data: result.data,
                        result: result,
                        response: result.response,
                        args: args,
                        requestOptions: requestOptions,
                        originalEvent: originalEvent,
                        url: url,
                        method: method
                    }));
                }
            }
            catch (ex) {
                error = ex;

                this.runHandler(onError, this.buildHandlerContext({
                    eventType: "form:error",
                    element: form,
                    triggerElement: submitButton || form,
                    error: ex,
                    args: args,
                    requestOptions: requestOptions,
                    originalEvent: originalEvent,
                    url: url,
                    method: method
                }));

                console.error("API form submit failed:", ex);
            }
            finally {
                this.clearBusy(form);
                if (submitButton) {
                    this.clearBusy(submitButton);
                }

                this.runHandler(onComplete, this.buildHandlerContext({
                    eventType: "form:complete",
                    element: form,
                    triggerElement: submitButton || form,
                    data: result ? result.data : null,
                    result: result,
                    response: result ? result.response : null,
                    error: error,
                    args: args,
                    requestOptions: requestOptions,
                    originalEvent: originalEvent,
                    url: url,
                    method: method
                }));
            }
        }
    }

    window.ApiHelper = new ApiHelperClass();
})(window, document);
