const ALLOWED_EMAILS = ["www", "info", "feedback", "mau"];

export const mailToLink = function (
  subject: string,
  user?: string,
  domain?: string
) {
  if (!domain) {
    domain = domain || "missionartists.org";
    if (!user || ALLOWED_EMAILS.indexOf(user) == -1) {
      user = "www";
    }
  }
  const lnk = `mailto:${user}@${domain}`;
  if (!subject) {
    return lnk;
  }
  return lnk + `?subject=${escape(subject)}`;
};
