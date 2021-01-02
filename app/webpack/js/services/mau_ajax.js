import angular from "angular";
import { camelize, camelizeKeys } from "humps";
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
  const options = {
    method,
    url,
    data,
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

const destroy = (url, data, ajaxOptions = {}) => {
  return request("delete", url, data, ajaxOptions);
};

const postForm = (formSelector) => {
  const $form = jQuery(formSelector);
  const formData = $form.serialize();
  const url = $form.attr("action");
  return post(url, formData);
};

// common pattern for angular $resource fetches
const responseTransformer = (key, fallbackReturnValue = null) => (data) => {
  const json = angular.fromJson(data);
  return json ? json[key] : fallbackReturnValue;
};

const responseCamelizeTransformer = (key, fallbackReturnValue = null) => (
  data
) => {
  const json = camelizeKeys(angular.fromJson(data));
  return json ? json[camelize(key)] : fallbackReturnValue;
};

export {
  ajaxSetup,
  destroy,
  get,
  post,
  postForm,
  responseCamelizeTransformer,
  responseTransformer,
};
