import 'global.dart';

const REACTOR_HTML = """
  <!DOCTYPE html>
  <html lang="ru">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      body {
        color: $HTML_CSS_COLOR;
        background: $HTML_CSS_BACKGROUND;
      }
      
      img {
        width: 100%;
        height: auto;
      }
      
      img:not(.$HTML_CLASS_POST_IMG_GIF) {
        object-fit: cover;
        object-position: 0 10px;
      }
      
      iframe {
        width: 100vw;
        height: 56.25vw;
      }
      
      a {
        color: inherit;
      }
      
      hr.$HTML_CLASS_POST_SEPARATOR {
        margin: 10px 0;
      }
    </style>
  </head>
  <body>
    <div>
      $HTML_CONTENT
    </div>
  </body>
  </html>
""";
