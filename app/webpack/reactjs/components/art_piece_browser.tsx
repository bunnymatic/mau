import { isEmpty } from "@js/app/helpers";
import Flash from "@js/app/jquery/flash";
import { ARROW_LEFT_KEY, ARROW_RIGHT_KEY } from "@js/event_constants";
import { routing } from "@js/services";
import { ArtPieceTagLink } from "@reactjs/components/art_piece_tag_link";
import { FavoriteThis } from "@reactjs/components/favorite_this";
import { JoinChildren } from "@reactjs/components/join_children";
import { LinkIf } from "@reactjs/components/link_if";
import { MediumLink } from "@reactjs/components/medium_link";
import { ShareButton } from "@reactjs/components/share_button";
import { Spinner } from "@reactjs/components/spinner";
import { useCarouselState, useEventListener } from "@reactjs/hooks";
import { Artist, ArtPiece, Studio } from "@reactjs/models";
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
  initialArtPieceId: number;
  artPieces: ArtPiece[];
  studio: Studio;
  artist: Artist;
}

const ArtPieceBrowser: FC<ArtPieceBrowserProps> = ({
  artist,
  artPieces,
  initialArtPieceId,
  studio,
}) => {
  const initialArtPiece = artPieces.find(
    (piece) => piece.id === initialArtPieceId
  );
  const { current, next, previous, setCurrent } = useCarouselState<ArtPiece>(
    artPieces,
    initialArtPiece
  );

  const keyDownHandler = useCallback((e) => {
    if (e.key === ARROW_LEFT_KEY) {
      previous();
    }
    if (e.key === ARROW_RIGHT_KEY) {
      next();
    }
  });

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
          <h2 className="title">
            <span className="art-piece__title">{current.title}</span>
            <span className="art-piece__byline-conjunction">by Artist</span>
            <span className="art-piece__byline">
              <a href={currentArtistPath}>{artist.fullName}</a>
            </span>
            {artist.doingOpenStudios && <OpenStudiosViolator />}
          </h2>
        </div>
      </div>
      <div className="pure-g alpha omega">
        <div className="pure-u-1-1 pure-u-sm-1-3 pure-u-md-1-4 pure-u-lg-1-5 art-piece__info">
          <section className="artist__image">
            <div className="artist-profile__image">
              <a href={currentArtistPath}>
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
            <div
              className="art-piece__image"
              style={{ backgroundImage: `url("${current.imageUrls.large}")` }}
            ></div>
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
                      onClick={(e) => {
                        e.preventDefault();
                        setCurrent(piece);
                      }}
                    >
                      <div
                        className="image"
                        style={{
                          backgroundImage: `url("${piece.imageUrls.small}")`,
                        }}
                      ></div>
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
  }, [artistId, artPieceId]);

  if (!artist || (!artPieces && !isEmpty(artPieces)) || !studio) {
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
      initialArtPieceId={artPieceId}
      artist={artist}
    />
  );
};

export { ArtPieceBrowserWrapper as ArtPieceBrowser };
