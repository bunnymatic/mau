import { isEmpty } from "@js/app/helpers";
import { SearchHit } from "@js/app/models/search_hit.model";
import { SearchResultsContext } from "@reactjs/components/search/search_results.context";
import { Spinner } from "@reactjs/components/spinner";
import cx from "classnames";
import React, { FC, useContext } from "react";

interface SearchResultProps {
  result: SearchHit;
}

const Name: FC<SearchResultProps> = ({ result }) => {
  if (result.type === "art_piece") {
    return (
      <>
        {result.name} <span className="byline-conjunction">by</span>{" "}
        <span className="artist-name">{result.artistName}</span>
      </>
    );
  }
  return <div>{result.name}</div>;
};

const Description: FC<SearchResultProps> = ({ result }) => {
  return (
    Boolean(result.description) && (
      <div className="desc">{result.description}</div>
    )
  );
};

const Medium: FC<SearchResultProps> = ({ result }) => {
  return (
    Boolean(result.medium) && (
      <div className="medium">
        <div className="label">Medium:</div>
        <div className="value">{result.medium}</div>
      </div>
    )
  );
};

const Tags: FC<SearchResultProps> = ({ result }) => {
  return (
    Boolean(result.tags) && (
      <div className="tags">
        <div className="label">Tags:</div>
        <div className="value">{result.tags}</div>
      </div>
    )
  );
};

const Image: FC<SearchResultProps> = ({ result }) => {
  if (!result.image) {
    return null;
  }
  return (
    <div className="thumb-col">
      <div
        className="img"
        style={{ backgroundImage: `url("${result.image}")` }}
      />
    </div>
  );
};

const SearchResult: FC<SearchResultProps> = ({ result }) => {
  return (
    <div className={cx("search-result", result.type)}>
      <div className="pure-g">
        <div className="pure-u-1-4 pure-u-md-4-24 pure-u-lg-2-24">
          {result.link && result.image && (
            <a href={result.link} title={result.name}>
              <Image result={result} />
            </a>
          )}
        </div>
        <div className="pure-u-3-4 pure-u-md-20-24 pure-u-lg-22-24">
          <a href={result.link} title={result.name}>
            <div className="hd pure-g">
              <div className="pure-u-1-1">
                <div className="score">{result.score}</div>
                <i role="img" className={cx("icon", result.iconClass)}></i>
                <div className="name">
                  {result.osParticipant && <div className="os-violator"></div>}
                  <Name result={result} />
                </div>
              </div>
            </div>
            <div className="bd pure-g">
              <div className="pure-u-4-5">
                <Description result={result} />
                <Medium result={result} />
                <Tags result={result} />
              </div>
            </div>
            <div className="ft"></div>
          </a>
        </div>
      </div>
    </div>
  );
};

export const SearchResults: FC = () => {
  const { results, loading } = useContext(SearchResultsContext);

  if (loading) {
    return <Spinner />;
  }

  if (!results || isEmpty(results)) {
    return null;
  }

  return (
    <div>
      {results.map((result) => (
        <SearchResult result={result} key={`${result.type}-${result.id}`} />
      ))}
    </div>
  );
};
