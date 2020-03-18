import jQuery from "jquery";

const ajaxSetup = jq => {
  let token = jq('meta[name="csrf-token"]').attr("content");
  jq.ajaxSetup({
    beforeSend: function(xhr) {
      xhr.setRequestHeader("X-CSRF-Token", token);
    }
  });
};

const request = (method, url, data, ajaxOptions = {}) => {
  ajaxSetup(jQuery);
  const options = {
    method,
    url,
    data,
    ...ajaxOptions
  };
  return jQuery.ajax(options);
};

const get = (url, data) => {
  return request("get", url, data);
};

const post = (url, data, ajaxOptions = {}) => {
  return request("post", url, data, ajaxOptions);
};

export { ajaxSetup, get, post };
