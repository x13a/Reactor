import 'page.dart';

const HTML_CONTENT = '%CONTENT%';
const HTML_CSS_COLOR = '%COLOR%';
const HTML_CSS_BACKGROUND = '%BACKGROUND%';
const HTML_CLASS_POSTS_SEPARATOR = 'posts-separator';

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
      
      img, video {
        width: 100%;
        height: auto;
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
      
      hr.$HTML_CLASS_POSTS_SEPARATOR {
        margin: 10px 0;
      }
      
      ${ReactorPost.contentSelector} {
        max-height: 2000px;
        overflow: hidden;
      }
      
      ${ReactorComment.contentSelector} {
        border: 1px solid;
        margin: 5px 0;
        padding: 5px;
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
