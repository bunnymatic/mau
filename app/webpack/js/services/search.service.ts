import { omit } from "@js/app/helpers";
import { api } from "@services/api";

type SearchQueryParams = Record<string, unknown>;
export const query = async function (
  searchParams: SearchQueryParams
): Promise<unknown> {
  if (!searchParams.query) {
    return Promise.resolve([]);
  }
  const params = omit(searchParams, "query");
  params.q = searchParams.query;
  return api.search.query(params);
};
