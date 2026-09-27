/**
 * @fileOverview Use jQuery Validate to provide validation and AJAX submission for form handling
 *
 * @author Tom Peer
 *
 * @module  clikForm
 * @version 1.1
 */

/**
* Return true if the field value matches the given format RegExp
*
* @memberOf module:clikForm
*
* @example $.validator.methods.pattern("AR1004",element,/^AR\d{4}$/)
* @result true
*
* @example $.validator.methods.pattern("BR1004",element,/^AR\d{4}$/)
* @result false
*
* @name $.validator.methods.pattern
* @type Boolean
* @cat Plugins/Validate/Methods
*/
$.validator.addMethod("pattern", function(value, element, param) {
	if (this.optional(element) && value === '') {
		return true;
	}
	if (typeof param === "string") {
		param = new RegExp(param);
	}
	return param.test(value);
}, "Invalid format.");


/**
* Shorthand for pattern validation of [A-Za-z0-9_]
*
* @example $.validator.methods.pattern("AR1004",element)
* @result true
*
* @example $.validator.methods.pattern("BR1004",element)
* @result false
*
* @name $.validator.methods.code
* @type Boolean
* @cat Plugins/Validate/Methods
*/
$.validator.addMethod("code", function(value, element) {
	var re = new RegExp("^[A-Za-z0-9_]*$");
	return (this.optional(element) && value === '') || re.test(value);
}, "Please enter only letters, numbers or the underscore character");


(function($) {
	function getInputsByName($form, name) {
		return $form.find("[name='" + name.replace(/'/g, "\\'") + "']");
	}

	function getField($form, fieldName) {
		var $inputs = getInputsByName($form, fieldName);
		if (!$inputs.length && fieldName.indexOf("[]") === -1) {
			$inputs = $form.find("[name='" + fieldName.replace(/'/g, "\\'") + "[]']");
		}
		if (!$inputs.length) {
			return $();
		}

		return $inputs.first().closest(".field");
	}

	function clearFieldError($form, fieldName) {
		var $field = getField($form, fieldName);
		if (!$field.length) {
			return;
		}
		$field.find("> .error").remove();
		$field.removeClass("error").addClass("valid");
	}

	function addFieldError($form, fieldName, message) {
		var $field = getField($form, fieldName);
		if (!$field.length) {
			return;
		}
		$field.find("> .error").remove();
		$field.removeClass("valid").addClass("error");
		$field.append("<div class='error clikFormError'>" + message + "</div>");
	}

	function buildApiSubmitOptions($form, options) {
		var submitMode = options.submit_mode || options.submitMode || $form.data("submit-mode") || "form";
		var jsonFieldName = options.json_field_name || options.jsonFieldName || $form.data("json-field-name") || "data";
		var submitMethod = options.submit_method || options.submitMethod || options.method || $form.attr("method") || "POST";

		return {
			submitMode: submitMode,
			jsonFieldName: jsonFieldName,
			method: submitMethod,
			headers: options.headers || {},
			url: options.url || $form.attr("action")
		};
	}

	function runOptionHandler(handler, payload) {
		if (!handler) {
			return;
		}

		if (typeof handler === "function") {
			handler(payload);
			return;
		}

		if (typeof handler === "string" && window.ApiHelper && typeof ApiHelper.runHandler === "function") {
			ApiHelper.runHandler(handler, payload);
		}
	}

	function showErrors($form, validator, errorMap, debug) {
		errorMap = errorMap || {};

		console.log("clikForm showErrors", errorMap);
		
		var fieldNames = {};
		$form.find("input[name], select[name], textarea[name]").each(function() {
			var $input = $(this);
			var type = $input.attr("type");
			if ((type && type === "hidden") || $input.is(":hidden")) {
				return;
			}
			fieldNames[$input.attr("name")] = true;
		});

		Object.keys(errorMap).forEach(function(name) {
			fieldNames[name] = true;
		});

		Object.keys(fieldNames).forEach(function(name) {
			var error = errorMap[name];

			if (error) {
				addFieldError($form, name, error);
				return;
			}

			var $inputs = getInputsByName($form, name);
			if (!$inputs.length && name.indexOf("[]") === -1) {
				$inputs = $form.find("[name='" + name.replace(/'/g, "\\'") + "[]']");
			}

			if (validator && $inputs.length && validator.check($inputs[0])) {
				clearFieldError($form, name);
			}
		});
	}

	/**
	 * Validates a form and submits it through ApiHelper.
	 *
	 * @memberOf module:clikForm
	 *
	 * @param  {object} ops Options
	 * @param {string} [ops.message] Success message to show on successful submission
	 * @param {string} [ops.error_message] Error message to show if submission wasn't successful
	 * @param {string} [ops.submit_mode] ApiHelper submit mode (`form`, `json`, `jsonField`, `formPlusJsonField`)
	 * @param {string} [ops.submit_method] HTTP method for ApiHelper request (default `POST`)
	 * @param {string} [ops.json_field_name] Field name used when submit mode contains JSON field payload
	 * @param {boolean} [ops.show_success_message] Display success message via ApiHelper.showMessage
	 * @param {Function|string} [ops.on_success] Callback or ApiHelper handler name called after successful response
	 * @param {Function|string} [ops.on_error] Callback or ApiHelper handler name called after failed response
	 * @param {Function|string} [ops.on_complete] Callback or ApiHelper handler name always called when request finishes
	 * @return {jQuery} Returns `this` for easy chaining
	 */
	$.fn.clikForm = function(ops) {
		var defaults = {
			debug: false,
			rules: {},
			message: "Thank you",
			messages: {},
			error_message: "Sorry, a network error occurred",
			submit_mode: "form",
			submit_method: "POST",
			json_field_name: "data",
			headers: {},
			method: null,
			url: null,
			show_success_message: true,
			on_success: null,
			on_error: null,
			on_complete: null
		};
		var options = $.extend({}, defaults, ops);

		return this.each(function() {
			var $cs = $(this);
			var $form = $cs.find("form");
			var validator;
			var formElement = $form[0];

			var $panel = $cs.find("div.contentInner");
			if ($panel.length !== 0) {
				$cs = $panel;
			}

			$form.find("select").select2();
			$form.find("textarea.elastic").elastic();

			if (formElement && !formElement.__clikFormSubmitPatched) {
				formElement.__clikFormSubmitPatched = true;
				formElement.__clikFormNativeSubmit = formElement.submit;
				formElement.submit = function() {
					var submitEvent = $.Event("submit");
					$(formElement).trigger(submitEvent);

					if (!submitEvent.isDefaultPrevented()) {
						formElement.__clikFormNativeSubmit.call(formElement);
					}
				};
			}

			validator = $form.validate({
				rules: options.rules,
				message: options.message,
				messages: options.messages,
				showErrors: function(errorMap) {
					showErrors($form, validator, errorMap, options.debug);
				},
				debug: options.debug,
				errorPlacement: function(error, element) {
					var $errorContainer = $form.find(".validateError[data-field=" + element.attr("name") + "]");
					if ($errorContainer.length) {
						error.appendTo($errorContainer);
					}
					$form.find("#question" + element.attr("name")).first().addClass("error");
				},
				unhighlight: function(element, sClass) {
					$(element)
						.addClass("valid")
						.removeClass(sClass);
					$form.find("#question" + $(element).attr("name")).first().removeClass("error");
				},
				ignore: ":hidden:not(.ratingList input)",
				submitHandler: function() {
					var submitOptions = buildApiSubmitOptions($form, options);
					var completePayload;
					var requestPromise = ApiHelper.submitJQueryForm($form, submitOptions);

					$form.find(":input").attr("disabled", true).css("opacity", 0.3);

					requestPromise
						.then(function(result) {
							var data = result && result.data !== undefined ? result.data : result;
							completePayload = {
								form: $form,
								container: $cs,
								result: result,
								data: data,
								options: options
							};

							$form.find(":input").attr("disabled", false).css("opacity", 1);

							console.log(data);

							if (data === true || (data && data.OK)) {
								console.log(`data ok`);

								runOptionHandler(options.on_success, completePayload);

								if (data !== true && data.NEXTPAGE) {
									$cs.html("<div class='loading'></div>");
									window.location.href = data.NEXTPAGE;
								}
								else {
									var msg = (data && data.MESSAGE) || options.message;
									if (options.show_success_message && window.ApiHelper && typeof ApiHelper.showMessage === "function") {
										ApiHelper.showMessage({
											type: "success",
											text: msg,
											display: "bar"
										});
									}
									else {
										$cs.html(msg);
									}
								}
							}
							else {
								
								runOptionHandler(options.on_error, completePayload);

								$cs.find(">.error").remove();
								var topMessage = (data && data.MESSAGE) ? data.MESSAGE : options.error_message;

								if (data && data["g-recaptcha-response"] !== undefined && data["g-recaptcha-response"] !== "") {
									$form.find("#recaptcha_widget_" + data["g-recaptcha-response"])
										.find(">.validateError").remove().end()
										.append("<div class='validateError'><p> " + data[data["g-recaptcha-response"]] + "</p></div>");
								}

								$cs.prepend("<div class='error'>" + topMessage + "</div>");
								showErrors($form, validator, data, options.debug);

								if ("grecaptcha" in window) {
									grecaptcha.reset();
								}

								$cs.find(":input:disabled").attr("disabled", false).css("opacity", 1);
							}
						})
						.catch(function(error) {
							completePayload = {
								form: $form,
								container: $cs,
								error: error,
								options: options
							};
							
							runOptionHandler(options.on_error, completePayload);

							var msg = options.error_message;
							$cs.html(msg);
							$form.find(":input").attr("disabled", false).css("opacity", 1);

							console.error("clikForm submission failed", error);
							
						})
						.finally(function() {
							runOptionHandler(options.on_complete, completePayload || {
								form: $form,
								container: $cs,
								options: options
							});
						});

					return false;
				}
			});
		});
	};
}(jQuery));
