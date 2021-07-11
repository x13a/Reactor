import 'global.dart';

const REACTOR_HTML = """
  <!DOCTYPE html>
  <html lang="ru">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      body {
        color: $VAR_COLOR;
        background: $VAR_BACKGROUND;
      }
      
      img {
        width: 100%;
        height: auto;
      }
      
      img:not(.$CLASS_NAME_POST_IMG_GIF) {
        object-fit: cover;
        object-position: 0 10px;
      }
      
      iframe {
        width: 100vw;
        height: 56.25vw;
      }
      
      hr.$CLASS_NAME_POST_SEPARATOR {
      a {
        color: inherit;
      }
      
        margin: 10px 0;
      }
    </style>
  </head>
  <body>
    <div>
      $VAR_CONTENT
    </div>
  </body>
  </html>
""";
