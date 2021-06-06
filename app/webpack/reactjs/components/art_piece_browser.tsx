import { isEmpty } from "@js/app/helpers";
import Flash from "@js/app/jquery/flash";
import { routing } from "@js/services";
import { ArtPieceTagLink } from "@reactjs/components/art_piece_tag_link";
import { FavoriteThis } from "@reactjs/components/favorite_this";
import { LinkIf } from "@reactjs/components/link_if";
import { MediumLink } from "@reactjs/components/medium_link";
import { ShareButton } from "@reactjs/components/share_button";
import { Spinner } from "@reactjs/components/spinner";
import { Artist, ArtPiece, Studio } from "@reactjs/models";
import { jsonApi as api } from "@services/json_api";
import cx from "classnames";
import React, { FC, useEffect, useState } from "react";

interface ArtPieceBrowserProps {
  artistId: number;
  artPieceId: number;
}

const OpenStudiosViolator: FC = () => (
  <a href="/open_studios" title="I&#39;m doing Open Studios">
    <div className="os-violator os-violator--title"></div>
  </a>
);

export const ArtPieceBrowser: FC<ArtPieceBrowserProps> = ({
  artistId,
  artPieceId,
}) => {
  const [artist, setArtist] = useState<Artist | undefined>();
  const [artPieces, setArtPieces] = useState<ArtPiece[]>([]);
  const [studio, setStudio] = useState<Studio | undefined>();
  const [current, setCurrent] = useState<number>(artPieceId);

  useEffect(() => {
    const artistCall = api.artists.get(artistId);
    const artPiecesCall = api.artPieces.index(artistId);
    Promise.all([artistCall, artPiecesCall])
      .then(([artist, artPieces]) => {
        setArtist(artist);
        setArtPieces(artPieces);
        return api.studios.get(artist.studioId).then((studio) => {
          console.log(studio);
          setStudio(studio);
        });
      })
      .catch((err) => {
        console.log(err);
        new Flash().show({ error: "rats" + err });
      });
  }, [artistId, artPieceId]);

  if (!artist || (!artPieces && !isEmpty(artPieces)) || !studio) {
    return <Spinner />;
  }

  const artPiece = artPieces.find((piece) => piece.id == current);
  const currentArtistPath = routing.urlForModel("artist", artist);
  const profileImagePath = artist.profileImages?.small;
  const hasAddress = artist.address || studio.address;

  console.log({ artist, artPieces, studio });

  const isCurrent = (id) => current == id;
  return (
    <div className="art-piece-browser">
      <div className="pure-g sticky-header">
        <div className="pure-u-1-1 header padded-content">
          <h2 className="title">
            <span className="art-piece__title">{artPiece.title}</span>
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
                {Boolean(profileImagePath) ? (
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
            {hasAddress && (
              <div className="studio-address">
                <div className="studio-street">
                  {artist.streetAddress}
                  <a href={artist.mapUrl} target="_blank" title="map">
                    <i className="fa fa-map-marker"></i>
                  </a>
                </div>
                <div className="studio-city">{studio.city}</div>
              </div>
            )}
          </section>
          <section className="desc">
            {Boolean(artPiece.dimensions) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Dimensions</h4>
                <div className="dimensions">{artPiece.dimensions}</div>
              </div>
            )}
            {Boolean(artPiece.year) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Date</h4>
                <div className="date">{artPiece.year}</div>
              </div>
            )}
            {Boolean(artPiece.medium) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Medium</h4>
                <div className="media">
                  <MediumLink medium={artPiece.medium} />
                </div>
              </div>
            )}
            {Boolean(artPiece.tags) && (
              <div className="desc__item">
                <h4 className="art-piece__info-title">Tags</h4>
                <div className="tags">
                  {artPiece.tags.map((tag) => (
                    <ArtPieceTagLink tag={tag} key={tag.id} />
                  ))}
                </div>
              </div>
            )}
            {(Boolean(artPiece.displayPrice) || artPiece.sold) && (
              <div
                className={cx("desc__item", {
                  "desc__item--sold": artPiece.sold,
                })}
              >
                <h4 className="art-piece__info-title">Price</h4>
                <div className="price">{artPiece.displayPrice}</div>
              </div>
            )}
          </section>
          <div className="push">
            <div className="social-buttons">
              <div className="share">Share</div>
              <ShareButton share-button artPiece={artPiece} type="twitter" />
              <ShareButton share-button artPiece={artPiece} type="facebook" />
              <ShareButton share-button artPiece={artPiece} type="pinterest" />
              {artPiece.id && <FavoriteThis id={artPiece.id} type="ArtPiece" />}
            </div>
          </div>
        </div>
        <div className="pure-u-1-1 pure-u-sm-2-3 pure-u-md-3-4 pure-u-lg-4-5 art-piece">
          <div className="art-piece__wrapper">
            <div
              className="art-piece__image"
              style={{ backgroundImage: `url("${artPiece.imageUrls.large}")` }}
            ></div>
          </div>
        </div>
        {artPieces.length > 1 && (
          <div className="pure-u-1-1 art-piece__thumbs">
            <div className="pure-g browser">
              {artPieces.map((piece) => {
                console.log({ piece });
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
                        setCurrent(piece.id);
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
