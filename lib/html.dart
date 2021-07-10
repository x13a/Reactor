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
      
      iframe {
        width: 100%;
        height: calc(100vw / 1.778);
      }
      
      hr.$CLASS_NAME_POST_SEPARATOR {
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
