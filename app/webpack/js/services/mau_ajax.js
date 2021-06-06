import { isNil } from "@js/app/helpers";
import { decamelizeKeys } from "humps";
import jQuery from "jquery";

const ajaxSetup = (jq) => {
  let token = jq('meta[name="csrf-token"]').attr("content");
  jq.ajaxSetup({
    beforeSend: function (xhr) {
      xhr.setRequestHeader("X-CSRF-Token", token);
    },
  });
};

const request = (method, url, data, ajaxOptions = {}) => {
  ajaxSetup(jQuery);
  const cleanData = isNil(data) ? undefined : decamelizeKeys(data);
  const options = {
    method,
    url,
    data: cleanData,
    ...ajaxOptions,
  };
  return jQuery.ajax(options);
};

const get = (url, data) => {
  return request("get", url, data);
};

const post = (url, data, ajaxOptions = {}) => {
  return request("post", url, data, ajaxOptions);
};

const put = (url, data, ajaxOptions = {}) => {
  return request("put", url, data, ajaxOptions);
};

const destroy = (url, data, ajaxOptions = {}) => {
  return request("delete", url, data, ajaxOptions);
};

const postForm = (formSelector) => {
  const $form = jQuery(formSelector);
  const formData = $form.serialize();
  const url = $form.attr("action");
  return post(url, formData);
};

export { ajaxSetup, destroy, get, post, postForm, put };
