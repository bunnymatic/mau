import { omit } from "@js/app/helpers";
import { api } from "@js/services/api";

type SearchQueryParams = Record<string, any>;
export const query = async function (
  searchParams: SearchQueryParams
): Promise<any> {
  if (!searchParams.query) {
    return Promise.resolve([]);
  }
  const params = omit(searchParams, "query");
  params.q = searchParams.query;
  return api.search.query(params);
};
