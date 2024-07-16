import Flash from "@js/app/flash";
import { isEmpty } from "@js/app/helpers";
import { ARROW_LEFT_KEY, ARROW_RIGHT_KEY } from "@js/event_constants";
import { routing } from "@js/services";
import { ArtPiece } from "@models/art_piece.model";
import { Artist } from "@models/artist.model";
import { Studio } from "@models/studio.model";
import { ArtPieceTagLink } from "@reactjs/components/art_piece_tag_link";
import { FavoriteThis } from "@reactjs/components/favorite_this";
import { JoinChildren } from "@reactjs/components/join_children";
import { LinkIf } from "@reactjs/components/link_if";
import { MediumLink } from "@reactjs/components/medium_link";
import { ShareButton } from "@reactjs/components/share_button";
import { Spinner } from "@reactjs/components/spinner";
import { useCarouselState, useEventListener } from "@reactjs/hooks";
import { IdType } from "@reactjs/types";
import { jsonApi as api } from "@services/json_api";
import cx from "classnames";
import React, { FC, useCallback, useEffect, useState } from "react";

interface ArtPieceBrowserWrapperProps {
  artistId: number;
  artPieceId: number;
}

const OpenStudiosViolator: FC = () => (
  <a href="/open_studios" title="I&#39;m doing Open Studios">
    <div className="os-violator os-violator--title"></div>
  </a>
);

interface ArtPieceBrowserProps {
  artPieceId: IdType;
  artPieces: ArtPiece[];
  studio: Studio;
  artist: Artist;
}

const ArtPieceBrowser: FC<ArtPieceBrowserProps> = ({
  artist,
  artPieces,
  artPieceId,
  studio,
}) => {
  const initialArtPiece = artPieces.find(
    (piece) => piece.id.toString() === artPieceId.toString()
  );
  const {
    current,
    next: _next,
    previous: _previous,
    setCurrent: _setCurrent,
  } = useCarouselState<ArtPiece>(artPieces, initialArtPiece);

  const updateHash = useCallback((piece: ArtPiece) => {
    window.history.pushState({}, document.title, `#${piece.id}`);
  }, []);

  const setCurrent = useCallback(
    (piece: ArtPiece) => {
      _setCurrent(piece);
      updateHash(piece);
    },
    [updateHash, _setCurrent]
  );

  const previous = useCallback(() => {
    const newCurrent = _previous();
    updateHash(newCurrent);
  }, [updateHash, _previous]);

  const next = useCallback(() => {
    const newCurrent = _next();
    updateHash(newCurrent);
  }, [updateHash, _next]);

  const keyDownHandler = useCallback(
    (e) => {
      if (e.key === ARROW_LEFT_KEY) {
        previous();
      }
      if (e.key === ARROW_RIGHT_KEY) {
        next();
      }
    },
    [previous, next]
  );

  useEventListener("keydown", keyDownHandler);

  const currentArtistPath = routing.urlForModel("artist", artist);
  const profileImagePath = artist.profileImages?.small;
  const isCurrent = (id) => current.id == id;

  if (!current) {
    return null;
  }
  return (
    <div className="art-piece-browser">
      <div className="pure-g sticky-header">
        <div className="pure-u-1-1 header padded-content">
          <h2 className="title art-piece__title-container">
            <span className="art-piece__title">{current.title}</span>{" "}
            <span className="art-piece__byline-conjunction">by Artist</span>{" "}
            <span className="art-piece__byline">
              <a href={currentArtistPath} title={`${artist.fullName}'s page`}>
                {artist.fullName}
              </a>
            </span>
            {artist.doingOpenStudios && <OpenStudiosViolator />}
          </h2>
        </div>
      </div>
      <div className="pure-g alpha omega">
        <div className="pure-u-1-1 pure-u-sm-1-3 pure-u-md-1-4 pure-u-lg-1-5 art-piece__info">
          <section className="artist__image">
            <div className="artist-profile__image">
              <a href={currentArtistPath} title={`${artist.fullName}'s page`}>
                {profileImagePath ? (
                  <img className="pure-img profile" src={profileImagePath} />
                ) : (
                  <i className="fa fa-user"></i>
                )}
              </a>
              {artist.doingOpenStudios && <OpenStudiosViolator />}
            </div>
          </section>
          <section className="artist__studio">
            <h4 className="studio-title">Studio</h4>
            <div className="studio">
              <LinkIf href={studio?.url} label={studio?.name} />
            </div>
            {artist.hasAddress && (
              <div className="studio-address">
                <div className="studio-street">
                  {artist.streetAddress}{" "}
                  <a href={artist.mapUrl} target="_blank" title="map">
                    <i className="fa fa-map-marker"></i>
                  </a>
                </div>
                <div className="studio-city">{studio.city}</div>
              </div>
            )}
          </section>
          <section className="desc">
            {Boolean(current.dimensions) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Dimensions</h4>
                <div className="dimensions">{current.dimensions}</div>
              </div>
            )}
            {Boolean(current.year) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Date</h4>
                <div className="date">{current.year}</div>
              </div>
            )}
            {Boolean(current.medium) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Medium</h4>
                <div className="media">
                  <MediumLink medium={current.medium} />
                </div>
              </div>
            )}
            {!isEmpty(current.tags) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Tags</h4>
                <div className="tags">
                  <JoinChildren separator=", ">
                    {current.tags.map((tag) => (
                      <ArtPieceTagLink tag={tag} key={tag.id} />
                    ))}
                  </JoinChildren>
                </div>
              </div>
            )}
            {(Boolean(current.displayPrice) || current.hasSold) && (
              <div
                className={cx("desc__item", {
                  "desc__item--sold": current.hasSold,
                })}
              >
                <h4 className="art-piece__info-title">Price</h4>
                <div className="price">{current.displayPrice}</div>
              </div>
            )}
          </section>
          <div className="push">
            <div className="social-buttons">
              <div className="share">Share</div>
              <ShareButton
                share-button
                artPiece={current}
                type="twitter"
              />{" "}
              <ShareButton share-button artPiece={current} type="facebook" />{" "}
              <ShareButton share-button artPiece={current} type="pinterest" />{" "}
              {current.id && <FavoriteThis id={current.id} type="ArtPiece" />}
            </div>
          </div>
        </div>
        <div className="pure-u-1-1 pure-u-sm-2-3 pure-u-md-3-4 pure-u-lg-4-5 art-piece">
          <div className="art-piece__wrapper">
            {current.imageUrls.large ? (
              <div
                className="art-piece__image"
                style={{ backgroundImage: `url("${current.imageUrls.large}")` }}
              ></div>
            ) : (
              <div className="art-piece__image art-piece__image--missing-url"></div>
            )}
          </div>
        </div>
        {artPieces.length > 1 && (
          <div className="pure-u-1-1 art-piece__thumbs">
            <div className="pure-g browser">
              {artPieces.map((piece) => {
                return (
                  <div
                    key={piece.id}
                    className={cx(
                      "piece pure-u-1-4 pure-u-sm-1-6 pure-u-md-1-8 pure-u-lg-1-10 padded-content",
                      { current: isCurrent(piece.id) }
                    )}
                  >
                    <a
                      href={`/art_pieces/${piece.id}`}
                      title={piece.title}
                      onClick={(e) => {
                        e.preventDefault();
                        setCurrent(piece);
                      }}
                    >
                      {piece.imageUrls.small ? (
                        <div
                          className="image"
                          style={{
                            backgroundImage: `url("${piece.imageUrls.small}")`,
                          }}
                        ></div>
                      ) : (
                        <div className="image image--missing-url"></div>
                      )}
                    </a>
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

const ArtPieceBrowserWrapper: FC<ArtPieceBrowserWrapperProps> = ({
  artistId,
  artPieceId,
}) => {
  const [artist, setArtist] = useState<Artist | undefined>();
  const [artPieces, setArtPieces] = useState<ArtPiece[]>([]);
  const [studio, setStudio] = useState<Studio | undefined>();
  const [initialArtPieceId, setInitialArtPieceId] = useState<string>(
    artPieceId.toString()
  );

  useEffect(() => {
    const artistCall = api.artists.get(artistId);
    const artPiecesCall = api.artPieces.index(artistId);
    Promise.all([artistCall, artPiecesCall])
      .then(([artist, artPieces]) => {
        setArtist(artist);
        setArtPieces(artPieces);
        return api.studios.get(artist.studioId).then((studio) => {
          setStudio(studio);
        });
      })
      .catch((err) => {
        new Flash().show({ error: "rats" + err });
      });
  }, [artistId]);

  useEffect(() => {
    if (window.location.hash) {
      setInitialArtPieceId(window.location.hash.substring(1));
    }
  }, []);

  if (!artist || (!artPieces && isEmpty(artPieces)) || !studio) {
    return (
      <div className="mau-spinner-wrapper--takeover">
        <Spinner />
      </div>
    );
  }
  return (
    <ArtPieceBrowser
      studio={studio}
      artPieces={artPieces}
      artPieceId={Number(initialArtPieceId)}
      artist={artist}
    />
  );
};

export { ArtPieceBrowserWrapper as ArtPieceBrowser };
