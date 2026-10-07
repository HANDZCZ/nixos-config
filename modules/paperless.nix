{ lib, ... }:

{
  services.paperless = {
    enable = true;
    address = lib.mkDefault "0.0.0.0";
    database.createLocally = true;
    configureTika = true;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "ces+eng";
      PAPERLESS_DATE_PARSER_LANGUAGES = "cs+en-US";
      PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = false;
    };
  };
}
